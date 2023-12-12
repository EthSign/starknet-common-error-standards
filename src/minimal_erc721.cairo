// SPDX-License-Identifier: MIT
// Based on OpenZeppelin Contracts for Cairo v0.8.0 (token/erc721/erc721.cairo)
// Modified by Jack Xu @ EthSign

#[starknet::contract]
mod MinimalERC721 {
    use core::zeroable::Zeroable;
    use starknet::{
        ContractAddress,
        get_caller_address,
    };
    use common_error_standards::{
        ierc721::{
            IERC721,
            ERC721Events::{
                Approval,
                ApprovalForAll,
                Transfer,
            },
        },
        components::erc721_errors::ERC721ErrorsComponent,
    };

    component!(path: ERC721ErrorsComponent, storage: erc721_errors, event: ERC721ErrorsEvent);

    #[abi(embed_v0)]
    impl ERC721Errors = ERC721ErrorsComponent::ERC721ErrorsImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721_errors: ERC721ErrorsComponent::Storage,
        owners: LegacyMap<u256, ContractAddress>,
        balances: LegacyMap<ContractAddress, u256>,
        token_approvals: LegacyMap<u256, ContractAddress>,
        operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721ErrorsEvent: ERC721ErrorsComponent::Event,
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self._mint(get_caller_address(), 1);
    }

    #[abi(embed_v0)]
    impl ERC721Impl of IERC721<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            'Test ERC721'
        }

        fn symbol(self: @ContractState) -> felt252 {
            'TEST'
        }

        fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
            ''
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            if account.is_zero() {
                self.throw_invalid_owner(account);
            }
            self.balances.read(account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.owners.read(token_id)
        }

        fn transfer_from(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            if !self._is_approved_or_owner(get_caller_address(), token_id) {
                self.throw_insufficient_approval(get_caller_address(), token_id);
            }
            let owner = self._owner_of(token_id);
            if !self._exists(token_id) {
                self.throw_nonexistent_token(token_id);
            } else if to.is_zero() {
                self.throw_invalid_receiver(to);
            } else if from != owner {
                self.throw_incorrect_owner(from, token_id, owner);
            }
            self.token_approvals.write(token_id, Zeroable::zero());
            self.balances.write(from, self.balances.read(from) - 1);
            self.balances.write(to, self.balances.read(to) + 1);
            self.owners.write(token_id, to);
            self.emit(Transfer { from, to, token_id });
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let owner = self._owner_of(token_id);
            let caller = get_caller_address();
            if owner != caller && !self.is_approved_for_all(owner, caller) {
                self.throw_invalid_approver(caller);
            }
            let owner = self._owner_of(token_id);
            self.token_approvals.write(token_id, to);
            self.emit(Approval { owner, approved: to, token_id });
        }

        fn set_approval_for_all(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let owner = get_caller_address();
            if operator.is_zero() || operator == owner {
                self.throw_invalid_operator(operator);
            }
            self.operator_approvals.write((owner, operator), approved);
            self.emit(ApprovalForAll { owner, operator, approved });
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            if !self._exists(token_id) {
                self.throw_nonexistent_token(token_id);
            }
            self.token_approvals.read(token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.operator_approvals.read((owner, operator))
        }
    }

    #[generate_trait]
    impl ERC721Internal of InternalTrait {
        fn _owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let owner = self.owners.read(token_id);
            if owner.is_zero() {
                self.throw_nonexistent_token(token_id);
            }
            owner
        }

        fn _exists(self: @ContractState, token_id: u256) -> bool {
            !self.owners.read(token_id).is_zero()
        }

        fn _is_approved_or_owner(
            self: @ContractState, spender: ContractAddress, token_id: u256
        ) -> bool {
            let owner = self._owner_of(token_id);
            let is_approved_for_all = self.is_approved_for_all(owner, spender);
            owner == spender || is_approved_for_all || spender == self.get_approved(token_id)
        }

        fn _mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
            if to.is_zero() {
                self.throw_invalid_receiver(to);
            }
            if self._exists(token_id) {
                self.throw_invalid_sender(Zeroable::zero());
            }
            self.balances.write(to, self.balances.read(to) + 1);
            self.owners.write(token_id, to);
            self.emit(Transfer { from: Zeroable::zero(), to, token_id });
        }
    }

}