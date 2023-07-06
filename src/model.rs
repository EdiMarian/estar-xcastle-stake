multiversx_sc::imports!();
multiversx_sc::derive_imports!();

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi)]
pub struct SftStaked<M: ManagedTypeApi> {
    pub nonce: u64,
    pub balance: BigUint<M>,
    pub staked_at: u64,
}

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi)]
pub struct Resource<M: ManagedTypeApi> {
    pub identifier: TokenIdentifier<M>,
    pub amount: BigUint<M>,
}