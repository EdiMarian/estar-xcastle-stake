#![no_std]

multiversx_sc::imports!();

pub mod model;
use model::*;
mod storage;

const ONE_DAY_IN_SECONDS: u64 = 86400;

#[multiversx_sc::contract]
pub trait StakeContract: storage::StorageModule {
    #[init]
    fn init(&self, token: TokenIdentifier) {
        if self.token().is_empty() {
            self.token().set_token_id(token);
        }
    }

    #[payable("*")]
    #[endpoint(stake)]
    fn stake(&self) -> SCResult<()> {
        let token_payment = self.call_value().single_esdt();
        require!(self.token().get_token_id() == token_payment.token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        let current_time = self.blockchain().get_block_timestamp();

        if self.sfts_staked(&caller).is_empty() {
            let sft = SFTStaked {
                identifier: token_payment.token_identifier.clone(),
                nonce: token_payment.token_nonce.clone(),
                amount: token_payment.amount,
                deadline: &current_time + ONE_DAY_IN_SECONDS * 10,
                staked_at: current_time
            };
            self.sfts_staked(&caller).set(sft);
            self.users_staked().insert(caller);
        }  else {
            let mut sft = self.sfts_staked(&caller).get();
            sft.amount += token_payment.amount;
            sft.deadline = &current_time + ONE_DAY_IN_SECONDS * 10;
            sft.staked_at = current_time;
            self.sfts_staked(&caller).set(sft);
        };

        Ok(())
    }

    
    #[endpoint(unStake)]
    fn un_stake(&self, token_identifier: TokenIdentifier, nonce: u64, amount: BigUint) -> SCResult<()> {
        require!(self.token().get_token_id() == token_identifier, "Invalid identifier!");

        let caller = self.blockchain().get_caller();
        require!(!self.sfts_staked(&caller).is_empty(), "You don't have sfts at stake!");

        let mut sft = self.sfts_staked(&caller).get();
        let current_time = self.blockchain().get_block_timestamp();
        require!(current_time >= sft.deadline, "You have to wait for the 10 days to pass!");

        require!(sft.amount >= amount, "You don't have enough sfts to unstake!");

        if &sft.amount - &amount == BigUint::zero() {
            self.send().direct_esdt(&caller, &token_identifier, nonce, &amount);
            self.sfts_staked(&caller).clear();
            self.users_staked().remove(&caller);
        } else {
            self.send().direct_esdt(&caller, &token_identifier, nonce, &amount);
            sft.amount -= amount.clone();
            self.sfts_staked(&caller).set(sft);
        }
        Ok(())
    }
}
