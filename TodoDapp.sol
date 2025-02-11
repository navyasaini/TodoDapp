//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TodoList{
    struct Todo{
        uint id;
        string content;
        bool completed;
        address creator;
    }

    //array to store todo items
    Todo[] public todos;

    // map user address to number of todos that user made
    mapping(address => uint) public userTodoCount;

    //events fo tracking todo actions
    event TodoCreated(uint id, string content, address creator);
    event TodoCompleted(uint id, bool completed);
    event TodoDeleted(uint id);
    event TodoUpdate(uint id, string newContent);


    //function modifier, to check ownership of todo
    modifier onlyCreator(uint _id){
        require(todos[_id].creator==msg.sender,"only the creater can modify this todo");
        _;
    }
    
    //functions
    //function to create new todo item
    function createTodo(string memory _content) public{
        //check if input has some length or not
        require(bytes(_content).length >0,"todo content cannot be empty");

        uint id = todos.length;
        todos.push(Todo({
            id:id,
            content:_content,
            completed:false,
            creator: msg.sender
        }));
    
        userTodoCount[msg.sender]++;
        //to save it on chain
        emit TodoCreated(id,_content,msg.sender);
    }

    //mark to do as completed or not
    function  toggleCompleted(uint _id) public onlyCreator(_id){
        todos[_id].completed=!todos[_id].completed;
        emit  TodoCompleted(_id,todos[_id].completed);
    }

    //update todo
    function updateTodo(uint _id, string memory _newContent) public onlyCreator(_id){
        //check if new content has length
         require(bytes(_newContent).length >0,"todo content cannot be empty");
        todos[_id].content=_newContent;
        emit TodoUpdate(_id, _newContent);
    }

    //function to delete
    function deleteTodo(uint _id) public onlyCreator(_id){
        //replace the todo with last todo in array to delete
        todos[_id]=todos[todos.length-1];

        //update id
        todos[_id].id=_id;

        //remove the last item
        todos.pop();
        userTodoCount[msg.sender]--;

        emit TodoDeleted(_id);
    }

    function getAllTodos() public view returns(Todo[] memory){
        return todos;
    }

    function getUserTodos() public view returns(Todo[] memory){
        Todo[] memory usertodos=new Todo[](userTodoCount[msg.sender]);
        uint counter=0;
        for(uint i=0; i<todos.length; i++){
            usertodos[counter]=todos[i];
            counter++;
        }

        return usertodos;
    }
    
    function getTotalTodoCount() public view returns (uint){
        return todos.length; //all todos on platform on all accounts together
    }
}
