multiversx_sc::imports!();

use crate::model::SftStaked;
use crate::storage;
use crate::heap::Vec;
use crate::ONE_DAY_IN_SECONDS;

#[multiversx_sc::module]
pub trait ViewsModule: storage::StorageModule {

    #[view(getSftsStaked)]
    fn get_sfts_staked(&self, address: &ManagedAddress) -> Vec<SftStaked<Self::Api>> {
        let mut sfts = Vec::new();
        for sft_nonce in self.sfts_staked(address).iter() {
            let sft_staked = SftStaked {
                nonce: sft_nonce.clone(),
                balance: self.sft_staked_amount(address, &sft_nonce).get(),
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
        let sft_eccu = self.sft_eccu(&nonce).get();
        let sft_resource = self.sft_resource(&nonce).get();

        let days_staked = (current_time - staked_at) / ONE_DAY_IN_SECONDS;

        if days_staked > 0u64 {
            let actual_reward = BigUint::from(days_staked) * amount_staked;
            match nonce {
                2 | 19 | 23 | 29 => {
                    self.user_food(address).update(|amount| *amount += sft_resource * actual_reward.clone());
                    self.user_eccu(address).update(|amount| *amount += sft_eccu * actual_reward);
                },
                35 | 41 | 49 | 55 => {
                    self.user_food(address).update(|amount| *amount += sft_resource * actual_reward);
                },
                37 | 43 | 51 | 57 => {
                    self.user_wood(address).update(|amount| *amount += sft_resource * actual_reward);
                },
                6 | 17 | 24 | 30 => {
                    self.user_food(address).update(|amount| *amount += sft_resource * actual_reward.clone());
                    self.user_eccu(address).update(|amount| *amount += sft_eccu * actual_reward);
                },
                34 | 40 | 47 | 54 => {
                    self.user_food(address).update(|amount| *amount += sft_resource * actual_reward);
                },
                3 | 16 | 22 | 27 => {
                    self.user_iron(address).update(|amount| *amount += sft_resource * actual_reward.clone());
                    self.user_eccu(address).update(|amount| *amount += sft_eccu * actual_reward);
                },
                36 | 42 | 50 | 56 => {
                    self.user_iron(address).update(|amount| *amount += sft_resource * actual_reward);
                },
                4 | 18 | 25 | 31 => {
                    self.user_wargear(address).update(|amount| *amount += sft_resource * actual_reward.clone());
                    self.user_eccu(address).update(|amount| *amount += sft_eccu * actual_reward);
                },
                33 | 39 | 46 | 53 => {
                    self.user_wargear(address).update(|amount| *amount += sft_resource * actual_reward);
                },
                38 | 44 | 52 | 58 => {
                    self.user_stone(address).update(|amount| *amount += sft_resource * actual_reward);
                },
                5 | 7 | 14 | 15 | 20 | 21 |26 | 28 => {
                    self.user_eccu(address).update(|amount| *amount += sft_eccu * actual_reward);
                },
                _ => {}
            }
        }
        return BigUint::zero();
    }
}