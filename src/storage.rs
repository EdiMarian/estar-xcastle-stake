multiversx_sc::imports!();

use crate::model::*;

#[multiversx_sc::module]
pub trait StorageModule {
    #[view(getToken)]
    #[storage_mapper("token")]
    fn token(&self) -> NonFungibleTokenMapper<Self::Api>;

    #[view(getPause)]
    #[storage_mapper("pause")]
    fn pause(&self) -> SingleValueMapper<bool>;

    #[view(getSftsStaked)]
    #[storage_mapper("sfts_staked")]
    fn sfts_staked(&self, address: &ManagedAddress) -> SingleValueMapper<SFTStaked<Self::Api>>;

    #[view(getSftsUnbond)]
    #[storage_mapper("sfts_unbond")]
    fn sfts_unbond(&self, address: &ManagedAddress) -> SingleValueMapper<SFTUnbond<Self::Api>>;

    #[view(getUsersStaked)]
    #[storage_mapper("users_staked")]
    fn users_staked(&self) -> SetMapper<ManagedAddress>;

    #[storage_mapper("user_rewards")]
    fn user_rewards(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUsersUnbond)]
    #[storage_mapper("users_unbond")]
    fn users_unbond(&self) -> SetMapper<ManagedAddress>;

    #[view(getTokenAmount)]
    #[storage_mapper("token_amount")]
    fn token_amount(&self) -> SingleValueMapper<BigUint>;
}