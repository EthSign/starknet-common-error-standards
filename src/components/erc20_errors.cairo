#[starknet::component]
mod ERC20ErrorsComponent {
    use starknet::ContractAddress;
    use common_error_standards::components::ierc20_errors::IERC20Errors;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[embeddable_as(ERC20ErrorsImpl)]
    impl ERC20Errors<TContractState, +HasComponent<TContractState>> of IERC20Errors<ComponentState<TContractState>> {
        fn throw_insufficient_balance(self: @ComponentState<TContractState>, sender: ContractAddress, balance: u256, needed: u256) {
            let data: Array<felt252> = array![
                'ERC20InsufficientBalance', 
                sender.into(), 
                balance.try_into().unwrap(), 
                needed.try_into().unwrap()
            ];
            panic(data);
        }

        fn throw_invalid_sender(self: @ComponentState<TContractState>, sender: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC20InvalidSender', 
                sender.into(),
            ];
            panic(data);
        }

        fn throw_invalid_receiver(self: @ComponentState<TContractState>, receiver: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC20InvalidReceiver', 
                receiver.into(),
            ];
            panic(data);
        }

        fn throw_insufficient_allowance(self: @ComponentState<TContractState>, spender: ContractAddress, allowance: u256, needed: u256) {
            let data: Array<felt252> = array![
                'ERC20InsufficientAllowance', 
                spender.into(),
                allowance.try_into().unwrap(),
                needed.try_into().unwrap(),
            ];
            panic(data);
        }

        fn throw_invalid_approver(self: @ComponentState<TContractState>, approver: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC20InvalidApprover', 
                approver.into(),
            ];
            panic(data);
        }

        fn throw_invalid_spender(self: @ComponentState<TContractState>, spender: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC20InvalidSpender', 
                spender.into(),
            ];
            panic(data);
        }
    }
}