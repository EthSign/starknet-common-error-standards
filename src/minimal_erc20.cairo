// SPDX-License-Identifier: MIT
// Based on OpenZeppelin Contracts for Cairo v0.8.0 (token/erc20/erc20.cairo)
// Modified by Jack Xu @ EthSign

#[starknet::contract]
mod MinimalERC20 {
    use integer::BoundedInt;
    use starknet::{
        ContractAddress,
        get_caller_address,
    };
    use common_error_standards::{
        ierc20::{
            IERC20,
            ERC20Events::{
                Approval,
                Transfer,
            },
        },
        components::erc20_errors::ERC20ErrorsComponent,
    };

    component!(path: ERC20ErrorsComponent, storage: erc20_errors, event: ERC20ErrorsEvent);

    #[abi(embed_v0)]
    impl ERC20Errors = ERC20ErrorsComponent::ERC20ErrorsImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20_errors: ERC20ErrorsComponent::Storage,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap<ContractAddress, u256>,
        allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20ErrorsEvent: ERC20ErrorsComponent::Event,
        Transfer: Transfer,
        Approval: Approval,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.name.write('Test ERC20');
        self.symbol.write('TEST');
        self._mint(get_caller_address(), 1000000);
    }

    #[abi(embed_v0)]
    impl ERC20Impl of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            self._transfer(get_caller_address(), recipient, amount);
            true
        }

        fn transfer_from(
            ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool {
            self._spend_allowance(sender, get_caller_address(), amount);
            self._transfer(sender, recipient, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            self._approve(get_caller_address(), spender, amount);
            true
        }
    }

    #[generate_trait]
    impl ERC20Internal of InternalTrait {
        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            if sender.is_zero() {
                self.throw_invalid_sender(sender);
            } else if recipient.is_zero() {
                self.throw_invalid_receiver(recipient);
            }
            let current_sender_balance = self.balances.read(sender);
            if current_sender_balance < amount {
                self.throw_insufficient_balance(sender, current_sender_balance, amount);
            }
            self.balances.write(sender, current_sender_balance - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }

        fn _approve(
            ref self: ContractState,
            owner: ContractAddress,
            spender: ContractAddress,
            amount: u256
        ) {
            if owner.is_zero() {
                self.throw_invalid_approver(owner);
            } else if spender.is_zero() {
                self.throw_invalid_spender(spender);
            }
            self.allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
        }

        fn _spend_allowance(
            ref self: ContractState,
            owner: ContractAddress,
            spender: ContractAddress,
            amount: u256
        ) {
            let current_allowance = self.allowances.read((owner, spender));
            if current_allowance < amount {
                self.throw_insufficient_allowance(spender, current_allowance, amount);
            }
            if current_allowance != BoundedInt::max() {
                self._approve(owner, spender, current_allowance - amount);
            }
        }

        fn _mint(
            ref self: ContractState, recipient: ContractAddress, amount: u256
        ) {
            if recipient.is_zero() {
                self.throw_invalid_receiver(recipient);
            }
            self.total_supply.write(self.total_supply.read() + amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Transfer { from: Zeroable::zero(), to: recipient, value: amount });
        }
    }

}