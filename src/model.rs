multiversx_sc::imports!();
multiversx_sc::derive_imports!();

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi)]
pub struct SftStaked<M: ManagedTypeApi> {
    pub nonce: u64,
    pub balance: BigUint<M>,
    pub staked_at: u64,
}

#[derive(TopEncode, TopDecode, NestedEncode, NestedDecode, PartialEq, TypeAbi, ManagedVecItem)]
pub enum TokenType {
  Eccu,
  Food,
  Wood,
  Beer,
  Stone,
  Iron,
  Wargear,
}

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi, ManagedVecItem)]
pub struct TokenReward<M: ManagedTypeApi> {
    pub name: TokenType,
    pub amount: BigUint<M>,
}

impl<M: ManagedTypeApi> TokenReward<M> {
  pub fn new(name: TokenType, amount: BigUint<M>) -> Self {
    Self {
      name,
      amount
    }
  }
}
