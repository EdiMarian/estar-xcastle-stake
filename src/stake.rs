#![no_std]

multiversx_sc::imports!();

pub mod model;
use model::*;
mod storage;
mod views;

const ONE_DAY_IN_SECONDS: u64 = 86400;
const TOKEN_DECIMALS: u64 = 1000000000000000000;

#[multiversx_sc::contract]
pub trait StakeContract: storage::StorageModule + views::ViewsModule {
    #[init]
    fn init(&self, token: TokenIdentifier) {
        if self.token().is_empty() {
            self.token().set_token_id(token);
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
        require!(self.token().get_token_id() == token_payment.token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        let current_time = self.blockchain().get_block_timestamp();

        if self.sfts_staked(&caller).is_empty() {
            let sft = SFTStaked {
                identifier: token_payment.token_identifier.clone(),
                nonce: token_payment.token_nonce.clone(),
                amount: token_payment.amount,
                staked_at: current_time
            };
            self.sfts_staked(&caller).set(sft);
            self.users_staked().insert(caller);
        }  else {
            let mut sft = self.sfts_staked(&caller).get();

            let days_staked = (current_time - &sft.staked_at) / ONE_DAY_IN_SECONDS;
            self.user_rewards(&caller).update(|user_amount| *user_amount += BigUint::from(3u64) * &sft.amount * BigUint::from(days_staked));

            sft.amount += token_payment.amount;
            sft.staked_at = current_time;
            self.sfts_staked(&caller).set(sft);
        };

        Ok(())
    }

    
    #[endpoint(unStake)]
    fn un_stake(&self, token_identifier: TokenIdentifier, nonce: u64, amount: BigUint) -> SCResult<()> {
        require!(!self.pause().get(), "The stake is stopped!");
        require!(self.token().get_token_id() == token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        require!(!self.sfts_staked(&caller).is_empty(), "You don't have sfts at stake!");

        let mut sft = self.sfts_staked(&caller).get();
        let current_time = self.blockchain().get_block_timestamp();

        require!(sft.amount >= amount, "You don't have enough sfts to unstake!");

        if &sft.amount - &amount == BigUint::zero() {
            self.sfts_staked(&caller).clear();
            self.users_staked().remove(&caller);
        } else {
            sft.amount -= amount.clone();
            self.sfts_staked(&caller).set(&sft);
        }

        let days_staked = (current_time - &sft.staked_at) / ONE_DAY_IN_SECONDS;
        self.user_rewards(&caller).update(|user_amount| *user_amount += BigUint::from(3u64) * amount.clone() * BigUint::from(days_staked));
        
        if self.users_unbond().contains(&caller) {
            let mut sft_unbond = self.sfts_unbond(&caller).get();
            sft_unbond.amount += amount.clone();
            sft_unbond.deadline = current_time + ONE_DAY_IN_SECONDS * 3;
            self.sfts_unbond(&caller).set(sft_unbond);
        } else {
            let sft_unbond = SFTUnbond {
                identifier: token_identifier.clone(),
                nonce: nonce.clone(),
                amount: amount.clone(),
                deadline: current_time + ONE_DAY_IN_SECONDS * 3
            };
    
            self.sfts_unbond(&caller).set(sft_unbond);
            self.users_unbond().insert(caller);
        }
        Ok(())
    }

    #[endpoint(unBond)]
    fn un_bond(&self, token_identifier: TokenIdentifier, nonce: u64, amount: BigUint) -> SCResult<()> {
        require!(!self.pause().get(), "The stake is stopped!");
        require!(self.token().get_token_id() == token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        require!(!self.sfts_unbond(&caller).is_empty(), "You don't have sfts at unBond!");

        let mut sft = self.sfts_unbond(&caller).get();
        let current_time = self.blockchain().get_block_timestamp();
        require!(current_time >= sft.deadline, "You have to wait for the 3 days to pass!");

        require!(sft.amount >= amount, "You don't have enough sfts to unBond!");

        if &sft.amount - &amount == BigUint::zero() {
            self.sfts_unbond(&caller).clear();
            self.users_unbond().remove(&caller);
        } else {
            sft.amount -= amount.clone();
            self.sfts_unbond(&caller).set(sft);
        }
        self.send().direct_esdt(&caller, &token_identifier, nonce, &amount);
        Ok(())
    }

    #[endpoint(claimRewards)]
    fn claim(&self) {
        require!(!self.pause().get(), "The stake is stopped!");

        let caller = self.blockchain().get_caller();
        let reward = self.get_rewards(&caller);
        let current_time = self.blockchain().get_block_timestamp();

        require!(reward > BigUint::zero(), "Amount of estar must be greater than zero!");
        require!(reward <= self.token_amount().get(), "It is not enough token in SC!");

        if !self.sfts_staked(&caller).is_empty() {
            let mut sfts_staked = self.sfts_staked(&caller).get();
            sfts_staked.staked_at = current_time;
            self.sfts_staked(&caller).set(sfts_staked);
        }
        
        self.user_rewards(&caller).clear();

        self.token_amount().update(|amount| *amount -= &reward);
        let reward_to_payment = reward * BigUint::from(TOKEN_DECIMALS);
        self.send().direct_esdt(&caller, &TokenIdentifier::from("XAPES-1d15a5".as_bytes()), 0, &reward_to_payment);
    }
}
