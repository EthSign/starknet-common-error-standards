use starknet::ContractAddress;

#[starknet::interface]
trait IERC721Errors<TContractState> {
    fn throw_invalid_owner(self: @TContractState, owner: ContractAddress);
    fn throw_nonexistent_token(self: @TContractState, token_id: u256);
    fn throw_incorrect_owner(self: @TContractState, sender: ContractAddress, token_id: u256, owner: ContractAddress);
    fn throw_invalid_sender(self: @TContractState, sender: ContractAddress);
    fn throw_invalid_receiver(self: @TContractState, receiver: ContractAddress);
    fn throw_insufficient_approval(self: @TContractState, operator: ContractAddress, token_id: u256);
    fn throw_invalid_approver(self: @TContractState, approver: ContractAddress);
    fn throw_invalid_operator(self: @TContractState, operator: ContractAddress);
}