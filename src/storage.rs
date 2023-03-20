multiversx_sc::imports!();

#[multiversx_sc::module]
pub trait StorageModule {
    #[view(getCollection)]
    #[storage_mapper("collection")]
    fn collection(&self) -> NonFungibleTokenMapper<Self::Api>;

    #[view(getPause)]
    #[storage_mapper("pause")]
    fn pause(&self) -> SingleValueMapper<bool>;

    #[view(getSftsAllowed)]
    #[storage_mapper("sfts_allowed")]
    fn sfts_allowed(&self) -> SetMapper<u64>;

    #[storage_mapper("sfts_staked")]
    fn sfts_staked(&self, address: &ManagedAddress) -> SetMapper<u64>;

    #[view(getSftStakedAmount)]
    #[storage_mapper("sft_staked_amount")]
    fn sft_staked_amount(&self, address: &ManagedAddress, nonce: &u64) -> SingleValueMapper<BigUint>;

    #[view(getSftStakedAt)]
    #[storage_mapper("sft_staked_at")]
    fn sft_staked_at(&self, address: &ManagedAddress, nonce: &u64) -> SingleValueMapper<u64>;

    #[view(getSftReward)]
    #[storage_mapper("sft_reward")]
    fn sft_reward(&self, nonce: &u64) -> SingleValueMapper<BigUint>;

    #[view(getUsersStaked)]
    #[storage_mapper("users_staked")]
    fn users_staked(&self) -> SetMapper<ManagedAddress>;

    #[storage_mapper("user_rewards")]
    fn user_rewards(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getTokenPayment)]
    #[storage_mapper("token_payment")]
    fn token_payment(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getTokenAmount)]
    #[storage_mapper("token_amount")]
    fn token_amount(&self) -> SingleValueMapper<BigUint>;
}