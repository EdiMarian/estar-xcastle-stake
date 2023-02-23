multiversx_sc::imports!();

use crate::model::*;

#[multiversx_sc::module]
pub trait StorageModule {
    #[view(getToken)]
    #[storage_mapper("token")]
    fn token(&self) -> NonFungibleTokenMapper<Self::Api>;

    #[view(getSftsStaked)]
    #[storage_mapper("sfts_staked")]
    fn sfts_staked(&self, address: &ManagedAddress) -> SingleValueMapper<SFTStaked<Self::Api>>;

    #[view(getUsersStaked)]
    #[storage_mapper("users_staked")]
    fn users_staked(&self) -> SetMapper<ManagedAddress>;
}