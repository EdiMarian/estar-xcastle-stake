multiversx_sc::imports!();

use crate::storage;
use crate::ONE_DAY_IN_SECONDS;

#[multiversx_sc::module]
pub trait ViewsModule: storage::StorageModule {

    #[view(getRewards)]
    fn get_rewards(&self, address: &ManagedAddress) -> BigUint {
        let mut total = BigUint::zero();
        let reward_per_sft = BigUint::from(3u64);
        let current_time = self.blockchain().get_block_timestamp();
        let user_rewards = self.user_rewards(address).get();

        if !self.sfts_staked(address).is_empty() {
            let user_sfts_staked = self.sfts_staked(address).get();
            let days_staked = (current_time - user_sfts_staked.staked_at) / ONE_DAY_IN_SECONDS;

            if days_staked >= 1 {
                total += reward_per_sft * BigUint::from(days_staked) * user_sfts_staked.amount;
            }
        }

        if user_rewards > BigUint::zero() {
            total += user_rewards;
        }
        total
    }
}