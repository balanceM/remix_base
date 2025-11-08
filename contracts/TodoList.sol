// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// 任务清单
contract TodoList {
    struct Todo {
        string name;
        bool isCompleted;
    }

    Todo[] public todoList;

    function create(string memory name) external {
        Todo memory todo = Todo({
                                name: name, 
                                isCompleted: false
                            });
        todoList.push(todo);
    }

    // 修改任务名称
    function modifyName(uint256 index_, string memory name_) external {
        // 方法1: 直接修改，修改一个属性时候比较省 gas
        todoList[index_].name = name_;
    }
    function modifyName2(uint256 index_, string memory name_) external {
        // 方法2: 先获取储存到 storage，在修改，在修改多个属性的时候比较省 gas
        Todo storage temp = todoList[index_];
        temp.name = name_;
    }

    // 手动修改任务状态
    function modifyStatus(uint256 index_, bool status_) external {
        todoList[index_].isCompleted = status_;
    }

    // 自动切换toggle
    function toggleStatus(uint256 index_) external {
        todoList[index_].isCompleted = !todoList[index_].isCompleted;
        // 这样比较省 gas
        // Todo storage todo = todoList[index_];
        // todo.isCompleted = !todo.isCompleted;
    }

    // 获取任务
    //  memory : 2次拷贝
    // 拷贝操作（get1）需要支付 数据加载（从 storage 到 memory）的 gas 费用
    // 对于结构体中的字符串（string），还可能涉及动态数据的额外处理成本。
    function get1(uint256 index_) external view returns (string memory name_, bool status_) {
        Todo memory todo = todoList[index_];
        return (todo.name, todo.isCompleted);
    }
    // storage : 1次拷贝
    // 只是创建一个指向 storage 中原有数据的引用，不会发生数据拷贝
    // 仅在读取 todo.name 和 todo.isCompleted 时直接访问原始存储位置。
    function get2(uint256 index_) external view
        returns (string memory name_, bool status_) {
        Todo storage todo = todoList[index_];
        return (todo.name, todo.isCompleted);
    }
}