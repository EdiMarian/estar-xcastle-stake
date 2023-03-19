multiversx_sc::imports!();
multiversx_sc::derive_imports!();

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi)]
pub enum Category {
    None,
    Bank,
    Mill,
    Taverne,
    Watch_Tower,
    Forge,
    House
}