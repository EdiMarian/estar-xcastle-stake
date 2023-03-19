#![no_std]

multiversx_sc::imports!();

mod storage;
mod views;

const ONE_DAY_IN_SECONDS: u64 = 86400;
const TOKEN_DECIMALS: u64 = 1000000000000000000;

#[multiversx_sc::contract]
pub trait StakeContract: storage::StorageModule + views::ViewsModule {
    #[init]
    fn init(&self, collection: TokenIdentifier) {
        if self.collection().is_empty() {
            self.collection().set_token_id(collection);
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
    fn stake(&self) -> SCResult<()> {
        require!(!self.pause().get(), "The stake is stopped!");
        let token_payment = self.call_value().single_esdt();
        require!(self.collection().get_token_id() == token_payment.token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        let current_time = self.blockchain().get_block_timestamp();

        if self.sfts_staked(&caller).contains(&token_payment.token_nonce) {
            self.calculate_rewards_and_save(&token_payment.token_nonce, &caller);
            self.sft_staked_at(&token_payment.token_nonce).set(current_time);
            self.sft_staked_amount(&token_payment.token_nonce).update(|amount| *amount += token_payment.amount);
        } else {
            self.sfts_staked(&caller).insert(token_payment.token_nonce);
            self.sft_staked_amount(&token_payment.token_nonce).set(token_payment.amount);
            self.sft_staked_at(&token_payment.token_nonce).set(current_time);
        }

        if !self.users_staked().contains(&caller) {
            self.users_staked().insert(caller);
        }

        Ok(())
    }
    
    #[endpoint(unStake)]
    fn un_stake(&self, token_identifier: TokenIdentifier, nonce: u64, amount: BigUint) {
        require!(!self.pause().get(), "The stake is stopped!");
        require!(self.collection().get_token_id() == token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        require!(!self.sfts_staked(&caller).is_empty(), "You don't have sfts at stake!");
    }

    fn calculate_rewards_and_save(&self, nonce: &u64, address: &ManagedAddress) {
        let staked_at = self.sft_staked_at(nonce).get();
        let current_time = self.blockchain().get_block_timestamp();
        let sft_reward = self.sft_reward(nonce).get();

        let days_staked = (current_time - staked_at) / ONE_DAY_IN_SECONDS;

        if days_staked > 0u64 {
            let actual_reward = sft_reward * BigUint::from(days_staked);
            self.user_rewards(address).update(|amount| *amount += actual_reward);
        }
    }
}
