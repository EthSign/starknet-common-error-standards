use starknet::ContractAddress;

#[starknet::interface]
trait IERC20Errors<TContractState> {
    fn throw_insufficient_balance(self: @TContractState, sender: ContractAddress, balance: u256, needed: u256);
    fn throw_invalid_sender(self: @TContractState, sender: ContractAddress);
    fn throw_invalid_receiver(self: @TContractState, receiver: ContractAddress);
    fn throw_insufficient_allowance(self: @TContractState, spender: ContractAddress, allowance: u256, needed: u256);
    fn throw_invalid_approver(self: @TContractState, approver: ContractAddress);
    fn throw_invalid_spender(self: @TContractState, spender: ContractAddress);
}