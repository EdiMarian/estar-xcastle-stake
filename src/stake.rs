#![no_std]

multiversx_sc::imports!();

mod storage;
mod views;

const ONE_DAY_IN_SECONDS: u64 = 86400;
const TOKEN_DECIMALS: u64 = 1000000000000000000;

#[multiversx_sc::contract]
pub trait StakeContract: storage::StorageModule + views::ViewsModule {
    #[init]
    fn init(&self, collection: TokenIdentifier, token: TokenIdentifier) {
        if self.collection().is_empty() {
            self.collection().set_token_id(collection);
        }
        if self.token_payment().is_empty() {
            self.token_payment().set(token)
        }
    }

    #[only_owner]
    #[endpoint(togglePause)]
    fn toggle_pause(&self) {
        self.pause().update(|pause| *pause = !*pause);
    }

    #[only_owner]
    #[payable("*")]
    #[endpoint(fundSystem)]
    fn fund(&self) {
        let payment = self.call_value().single_esdt();

        require!(payment.amount > BigUint::zero(), "Amount must be greater than zero!");

        self.token_amount().update(|amount| *amount += payment.amount);
    }

    #[only_owner]
    #[payable("*")]
    #[endpoint(withdrawFunds)]
    fn withdraw(&self, withdraw_amount: BigUint) {
        let caller = self.blockchain().get_caller();
        require!(withdraw_amount > BigUint::zero(), "Amount must be greater than zero!");
        self.send().direct_esdt(&caller, &TokenIdentifier::from("XAPES-1d15a5".as_bytes()), 0, &withdraw_amount);
        self.token_amount().update(|amount| *amount -= &withdraw_amount);
    }

    #[payable("*")]
    #[endpoint(stake)]
    fn stake(&self) {
        require!(!self.pause().get(), "The stake is stopped!");
        let token_payment = self.call_value().single_esdt();
        require!(self.collection().get_token_id() == token_payment.token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        let current_time = self.blockchain().get_block_timestamp();

        if self.sfts_staked(&caller).contains(&token_payment.token_nonce) {
            self.calculate_rewards_and_save(&token_payment.token_nonce, &caller);
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
        require!(self.collection().get_token_id() == token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        require!(self.sfts_staked(&caller).contains(&nonce), "You don't have this sft at stake!");
        require!(self.sft_staked_amount(&caller, &nonce).get() > amount, "You don't have enough sfts at stake!");

        self.calculate_rewards_and_save(&nonce, &caller);
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

        self.send().direct_esdt(&caller, &token_identifier, nonce, &amount)
    }

    #[endpoint(claimRewards)]
    fn claim_rewards(&self) {
        let caller = self.blockchain().get_caller();
        require!(self.users_staked().contains(&caller), "You don't have sfts at stake!");
        let rewards = self.get_rewards(&caller);
        require!(rewards > BigUint::zero(), "You don't have rewards to claim!");

        self.reset_sfts_staked_time(&caller);
    }

    fn calculate_rewards_and_save(&self, nonce: &u64, address: &ManagedAddress) {
        let staked_at = self.sft_staked_at(address, nonce).get();
        let amount_staked = self.sft_staked_amount(address, nonce).get();
        let current_time = self.blockchain().get_block_timestamp();
        let sft_reward = self.sft_reward(nonce).get();

        let days_staked = (current_time - staked_at) / ONE_DAY_IN_SECONDS;

        if days_staked > 0u64 {
            let actual_reward = sft_reward * BigUint::from(days_staked) * amount_staked;
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
