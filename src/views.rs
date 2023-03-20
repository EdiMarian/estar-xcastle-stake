multiversx_sc::imports!();

use crate::model::SftStaked;
use crate::storage;
use crate::heap::Vec;
use crate::ONE_DAY_IN_SECONDS;

#[multiversx_sc::module]
pub trait ViewsModule: storage::StorageModule {

    #[view(getRewards)]
    fn get_rewards(&self, address: &ManagedAddress) -> BigUint {
        let mut total = BigUint::zero();
        for sft_nonce in self.sfts_staked(address).iter() {
            total += self.calculate_sft_reward(&sft_nonce, address);
        }

        let user_rewards = self.user_rewards(address).get();

        if user_rewards > BigUint::zero() {
            total += user_rewards;
        }

        total
    }

    #[view(getSftsStaked)]
    fn get_sfts_staked(&self, address: &ManagedAddress) -> Vec<SftStaked<Self::Api>> {
        let mut sfts = Vec::new();
        for sft_nonce in self.sfts_staked(address).iter() {
            let sft_staked = SftStaked {
                nonce: sft_nonce.clone(),
                amount: self.sft_staked_amount(address, &sft_nonce).get(),
                staked_at: self.sft_staked_at(address, &sft_nonce).get(),
            };
            sfts.push(sft_staked);
        }

        sfts
    }

    fn calculate_sft_reward(&self, nonce: &u64, address: &ManagedAddress) -> BigUint {
        let staked_at = self.sft_staked_at(address, nonce).get();
        let amount_staked = self.sft_staked_amount(address, nonce).get();
        let current_time = self.blockchain().get_block_timestamp();
        let sft_reward = self.sft_reward(nonce).get();

        let days_staked = (current_time - staked_at) / ONE_DAY_IN_SECONDS;

        if days_staked > 0u64 {
            let actual_reward = sft_reward * BigUint::from(days_staked) * amount_staked;
            return actual_reward;
        }
        return BigUint::zero();
    }
}