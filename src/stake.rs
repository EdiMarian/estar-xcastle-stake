#![no_std]

multiversx_sc::imports!();

mod storage;
pub mod model;
mod views;

const ONE_DAY_IN_SECONDS: u64 = 30;
const TOKEN_DECIMALS: u64 = 1;

#[multiversx_sc::contract]
pub trait StakeContract: storage::StorageModule + views::ViewsModule {
    #[init]
    fn init(&self, collection: TokenIdentifier, token: TokenIdentifier) {
        self.collection().set(collection);
        self.token_payment().set(token);
    }

    #[only_owner]
    #[endpoint(togglePause)]
    fn toggle_pause(&self) {
        self.pause().update(|pause| *pause = !*pause);
    }

    #[only_owner]
    #[endpoint(setSftsAllowed)]
    fn set_sfts_allowed(&self, sfts_allowed: MultiValueEncoded<u64>) {
        for sft_allowed in sfts_allowed.into_iter() {
            self.sfts_allowed().insert(sft_allowed);
        }
    }

    #[only_owner]
    #[endpoint(removeSftsAllowed)]
    fn remove_sfts_allowed(&self, sfts_removed: MultiValueEncoded<u64>) {
        for sft_removed in sfts_removed.into_iter() {
            self.sfts_allowed().remove(&sft_removed);
        }
    }

    #[only_owner]
    #[endpoint(setSftsReward)]
    fn set_sft_reward(&self, sfts_with_reward_amount: MultiValueEncoded<MultiValue2<u64, BigUint>>) {
        for sft_with_reward_amount in sfts_with_reward_amount.into_iter() {
            let (nonce, reward_amount) = sft_with_reward_amount.into_tuple();
            self.sft_reward(&nonce).set(reward_amount);
        }
    }

    #[only_owner]
    #[payable("*")]
    #[endpoint(fundSystem)]
    fn fund(&self) {
        let payment = self.call_value().single_esdt();
        require!(self.token_payment().get() == payment.token_identifier, "Invalid token!");
        require!(payment.amount > BigUint::zero(), "Amount must be greater than zero!");

        self.token_amount().update(|amount| *amount += payment.amount);
    }

    #[only_owner]
    #[payable("*")]
    #[endpoint(withdrawFunds)]
    fn withdraw(&self, withdraw_amount: BigUint) {
        let caller = self.blockchain().get_caller();
        require!(withdraw_amount > BigUint::zero(), "Amount must be greater than zero!");

        self.token_amount().update(|amount| *amount -= &withdraw_amount);
        self.send().direct_esdt(&caller, &self.token_payment().get(), 0, &withdraw_amount);
    }

    #[payable("*")]
    #[endpoint(stake)]
    fn stake(&self) {
        require!(!self.pause().get(), "The stake is stopped!");
        let token_payment = self.call_value().single_esdt();
        require!(self.collection().get() == token_payment.token_identifier, "Invalid identifier!");
        require!(self.sfts_allowed().contains(&token_payment.token_nonce), "Invalid sft nonce!");

        let caller = self.blockchain().get_caller();
        let current_time = self.blockchain().get_block_timestamp();

        if self.sfts_staked(&caller).contains(&token_payment.token_nonce) {
            self.calculate_rewards_and_save(&token_payment.token_nonce, &caller, &self.sft_staked_amount(&caller, &token_payment.token_nonce).get());
            self.sft_staked_at(&caller, &token_payment.token_nonce).set(current_time);
            self.sft_staked_amount(&caller, &token_payment.token_nonce).update(|amount| *amount += token_payment.amount);
        } else {
            self.sfts_staked(&caller).insert(token_payment.token_nonce);
            self.sft_staked_amount(&caller, &token_payment.token_nonce).set(token_payment.amount);
            self.sft_staked_at(&caller, &token_payment.token_nonce).set(current_time);
        }

        if !self.users_staked().contains(&caller) {
            self.users_staked().insert(caller);
        }
    }
    
    #[endpoint(unStake)]
    fn un_stake(&self, token_identifier: TokenIdentifier, nonce: u64, amount: BigUint) {
        require!(!self.pause().get(), "The stake is stopped!");
        require!(self.collection().get() == token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        require!(self.sfts_staked(&caller).contains(&nonce), "You don't have this sft at stake!");
        require!(self.sft_staked_amount(&caller, &nonce).get() >= amount, "You don't have enough sfts at stake!");

        self.calculate_rewards_and_save(&nonce, &caller, &amount);
        let amount_staked = self.sft_staked_amount(&caller, &nonce).get();

        if amount_staked - &amount > BigUint::zero() {
            self.sft_staked_amount(&caller, &nonce).update(|amount_on_stake| *amount_on_stake -= amount.clone());
        } else {
            self.sft_staked_amount(&caller, &nonce).clear();
            self.sft_staked_at(&caller, &nonce).clear();
            self.sfts_staked(&caller).remove(&nonce);
        }

        if self.sfts_staked(&caller).len() == 0 {
            self.users_staked().remove(&caller);
        }
        self.send().direct_esdt(&caller, &token_identifier, nonce, &amount);
    }

    #[endpoint(claimRewards)]
    fn claim_rewards(&self) {
        let caller = self.blockchain().get_caller();
        let rewards = self.get_rewards(&caller);
        require!(rewards > BigUint::zero(), "You don't have rewards to claim!");
        require!(self.token_amount().get() >= rewards, "There are not enough funds!");

        self.reset_sfts_staked_time(&caller);

        let rewards_after_dec = rewards.clone() * BigUint::from(TOKEN_DECIMALS);
        self.token_amount().update(|amount| *amount -= &rewards_after_dec);
        self.user_rewards(&caller).set(BigUint::zero());

        self.send().direct_esdt(&caller, &self.token_payment().get(), 0, &rewards_after_dec);
    }

    fn calculate_rewards_and_save(&self, nonce: &u64, address: &ManagedAddress, amount_to_unstake: &BigUint) {
        let staked_at = self.sft_staked_at(address, nonce).get();
        let current_time = self.blockchain().get_block_timestamp();
        let sft_reward = self.sft_reward(nonce).get();

        let days_staked = (current_time - staked_at) / ONE_DAY_IN_SECONDS;

        if days_staked > 0u64 {
            let actual_reward = sft_reward * BigUint::from(days_staked) * amount_to_unstake;
            self.user_rewards(address).update(|amount| *amount += actual_reward);
        }
    }

    fn reset_sfts_staked_time(&self, address: &ManagedAddress) {
        let current_time = self.blockchain().get_block_timestamp();

        for sft in self.sfts_staked(address).iter() {
            self.sft_staked_at(address, &sft).set(current_time);
        }
    }
}
