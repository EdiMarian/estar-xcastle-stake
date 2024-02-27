multiversx_sc::imports!();

#[multiversx_sc::module]
pub trait StorageModule {
    #[view(getCollection)]
    #[storage_mapper("collection")]
    fn collection(&self) -> SingleValueMapper<TokenIdentifier>;

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
    fn sft_staked_amount(
        &self,
        address: &ManagedAddress,
        nonce: &u64,
    ) -> SingleValueMapper<BigUint>;

    #[view(getSftStakedAt)]
    #[storage_mapper("sft_staked_at")]
    fn sft_staked_at(&self, address: &ManagedAddress, nonce: &u64) -> SingleValueMapper<u64>;

    #[view(getSftResource)]
    #[storage_mapper("sft_resource")]
    fn sft_resource(&self, nonce: &u64) -> SingleValueMapper<BigUint>;

    #[view(getUserFood)]
    #[storage_mapper("user_food")]
    fn user_food(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUserBeer)]
    #[storage_mapper("user_beer")]
    fn user_beer(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUserWood)]
    #[storage_mapper("user_wood")]
    fn user_wood(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUserStone)]
    #[storage_mapper("user_stone")]
    fn user_stone(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUserIron)]
    #[storage_mapper("user_iron")]
    fn user_iron(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUserWargear)]
    #[storage_mapper("user_wargear")]
    fn user_wargear(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getUsersStaked)]
    #[storage_mapper("users_staked")]
    fn users_staked(&self) -> SetMapper<ManagedAddress>;

    #[view(getFoodIdentifier)]
    #[storage_mapper("food_identifier")]
    fn food_identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getBeerIdentifier)]
    #[storage_mapper("beer_identifier")]
    fn beer_identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getWoodIdentifier)]
    #[storage_mapper("wood_identifier")]
    fn wood_identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getStoneIdentifier)]
    #[storage_mapper("stone_identifier")]
    fn stone_identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getIronIdentifier)]
    #[storage_mapper("iron_identifier")]
    fn iron_identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getWargearIdentifier)]
    #[storage_mapper("wargear_identifier")]
    fn wargear_identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getFoodAmount)]
    #[storage_mapper("food_amount")]
    fn food_amount(&self) -> SingleValueMapper<BigUint>;

    #[view(getBeerAmount)]
    #[storage_mapper("beer_amount")]
    fn beer_amount(&self) -> SingleValueMapper<BigUint>;

    #[view(getWoodAmount)]
    #[storage_mapper("wood_amount")]
    fn wood_amount(&self) -> SingleValueMapper<BigUint>;

    #[view(getStoneAmount)]
    #[storage_mapper("stone_amount")]
    fn stone_amount(&self) -> SingleValueMapper<BigUint>;

    #[view(getIronAmount)]
    #[storage_mapper("iron_amount")]
    fn iron_amount(&self) -> SingleValueMapper<BigUint>;

    #[view(getWargearAmount)]
    #[storage_mapper("wargear_amount")]
    fn wargear_amount(&self) -> SingleValueMapper<BigUint>;
}
