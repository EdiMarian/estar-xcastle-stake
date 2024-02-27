multiversx_sc::imports!();

use crate::model::SftStaked;
use crate::{storage, User};

#[multiversx_sc::module]
pub trait ViewsModule: storage::StorageModule {
    #[view(getSftsStaked)]
    fn get_sfts_staked(&self, address: &ManagedAddress) -> ManagedVec<SftStaked<Self::Api>> {
        let mut sfts = ManagedVec::new();
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

    #[view(getUsers)]
    fn get_users(&self) -> ManagedVec<User<Self::Api>> {
        let mut users = ManagedVec::new();

        for address in self.users_staked().iter() {
            let sfts = self.get_sfts_staked(&address);
            let user = User { address, sfts };
            users.push(user)
        }

        users
    }
}
