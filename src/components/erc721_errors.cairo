#[starknet::component]
mod ERC721ErrorsComponent {
    use starknet::ContractAddress;
    use common_error_standards::components::ierc721_errors::IERC721Errors;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[embeddable_as(ERC721ErrorsImpl)]
    impl ERC721Errors<TContractState, +HasComponent<TContractState>> of IERC721Errors<ComponentState<TContractState>> {
        fn throw_invalid_owner(self: @ComponentState<TContractState>, owner: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC721InvalidOwner', 
                owner.into(),
            ];
            panic(data);
        }

        fn throw_nonexistent_token(self: @ComponentState<TContractState>, token_id: u256) {
            let data: Array<felt252> = array![
                'ERC721NonexistentToken', 
                token_id.try_into().unwrap(),
            ];
            panic(data);
        }

        fn throw_incorrect_owner(self: @ComponentState<TContractState>, sender: ContractAddress, token_id: u256, owner: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC721IncorrectOwner', 
                sender.into(),
                token_id.try_into().unwrap(),
                owner.into(),
            ];
            panic(data);
        }

        fn throw_invalid_sender(self: @ComponentState<TContractState>, sender: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC721InvalidSender', 
                sender.into(),
            ];
            panic(data);
        }

        fn throw_invalid_receiver(self: @ComponentState<TContractState>, receiver: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC721InvalidReceiver', 
                receiver.into(),
            ];
            panic(data);
        }

        fn throw_insufficient_approval(self: @ComponentState<TContractState>, operator: ContractAddress, token_id: u256) {
            let data: Array<felt252> = array![
                'ERC721InsufficientApproval', 
                operator.into(),
                token_id.try_into().unwrap(),
            ];
            panic(data);
        }

        fn throw_invalid_approver(self: @ComponentState<TContractState>, approver: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC721InvalidApprover', 
                approver.into(),
            ];
            panic(data);
        }

        fn throw_invalid_operator(self: @ComponentState<TContractState>, operator: ContractAddress) {
            let data: Array<felt252> = array![
                'ERC721InvalidOperator', 
                operator.into(),
            ];
            panic(data);
        }
    }

}
