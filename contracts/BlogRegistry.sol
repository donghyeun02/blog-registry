// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlogRegistry {
    mapping(address => string[]) public userPosts;
    string[] public allPosts;
    
    struct PostInfo {
        string cid;
        address author;
        uint256 timestamp;
        bool exists;
    }
    
    mapping(string => PostInfo) public postDetails;
    
    event PostRegistered(address indexed author, string cid, uint256 timestamp);
    event PostDeleted(address indexed author, string cid, uint256 timestamp);
    event PostUpdated(address indexed author, string oldCid, string newCid, uint256 timestamp);
    
    function registerPost(string memory cid) public {
        require(bytes(cid).length > 0, "CID cannot be empty");
        require(!postDetails[cid].exists, "Post already exists");
        
        
        PostInfo memory newPost = PostInfo({
            cid: cid,
            author: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });
        
        postDetails[cid] = newPost;
        userPosts[msg.sender].push(cid);
        allPosts.push(cid);
        
        emit PostRegistered(msg.sender, cid, block.timestamp);
    }
    
    function getUserPosts(address user) public view returns (string[] memory) {
        return userPosts[user];
    }
    
    function getAllPosts() public view returns (string[] memory) {
        return allPosts;
    }
    
    function getPostCount() public view returns (uint256) {
        return allPosts.length;
    }
    
    function getPostInfo(string memory cid) public view returns (PostInfo memory) {
        require(postDetails[cid].exists, "Post does not exist");
        return postDetails[cid];
    }
    
    function deletePost(string memory cid) public {
        require(postDetails[cid].exists, "Post does not exist");
        require(postDetails[cid].author == msg.sender, "Only author can delete post");
        
        delete postDetails[cid];
        
        string[] storage userPostList = userPosts[msg.sender];
        for (uint i = 0; i < userPostList.length; i++) {
            if (keccak256(bytes(userPostList[i])) == keccak256(bytes(cid))) {
                userPostList[i] = userPostList[userPostList.length - 1];
                userPostList.pop();
                break;
            }
        }
        
        for (uint i = 0; i < allPosts.length; i++) {
            if (keccak256(bytes(allPosts[i])) == keccak256(bytes(cid))) {
                allPosts[i] = allPosts[allPosts.length - 1];
                allPosts.pop();
                break;
            }
        }
        
        emit PostDeleted(msg.sender, cid, block.timestamp);
    }
    
    function updatePost(string memory oldCid, string memory newCid) public {
        require(postDetails[oldCid].exists, "Old post does not exist");
        require(postDetails[oldCid].author == msg.sender, "Only author can update post");
        require(bytes(newCid).length > 0, "New CID cannot be empty");
        require(!postDetails[newCid].exists, "New CID already exists");
        
        PostInfo memory updatedPost = PostInfo({
            cid: newCid,
            author: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });
        
        postDetails[newCid] = updatedPost;
        
        string[] storage userPostList = userPosts[msg.sender];
        for (uint i = 0; i < userPostList.length; i++) {
            if (keccak256(bytes(userPostList[i])) == keccak256(bytes(oldCid))) {
                userPostList[i] = newCid;
                break;
            }
        }
        
        for (uint i = 0; i < allPosts.length; i++) {
            if (keccak256(bytes(allPosts[i])) == keccak256(bytes(oldCid))) {
                allPosts[i] = newCid;
                break;
            }
        }
        
        delete postDetails[oldCid];
        
        emit PostUpdated(msg.sender, oldCid, newCid, block.timestamp);
    }
    
    function getUserPostCount(address user) public view returns (uint256) {
        return userPosts[user].length;
    }
    
    function postExists(string memory cid) public view returns (bool) {
        return postDetails[cid].exists;
    }
} 