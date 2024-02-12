// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721NFT is ERC721, Ownable {
    string private constant TOKEN_URI = "ipfs://bafkreihz44beoastcalbfoyzbrye3qpqhcbkhincskual4mxra7cgqmf34";
    uint256 private s_tokenCounter;
    mapping(address => address[]) private subscriptions;
    mapping(address => uint256) private subscriberCount;
    mapping(address => address[]) private subscriptionRequests;
    mapping(address => UserProfile) public userProfiles;
    
    struct UserProfile {
        string name;
        string bio;
        string picture;
        bool walletConnected;
    }

    event SubscriptionRequestSent(address indexed from, address indexed to);
    event SubscriptionAccepted(address indexed subscriber, address indexed user);
    event SubscriptionRejected(address indexed subscriber, address indexed user);
    event UserRegistered(address indexed user, string name, string bio, string picture);
    event WalletConnected(address indexed user);

    constructor() ERC721("MyToken", "MTK") Ownable(msg.sender) {
        s_tokenCounter = 0;
    }

    function mintNft() private returns (uint256){
        _safeMint(msg.sender, s_tokenCounter++);
        return s_tokenCounter;
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory){
        require(ownerOf(tokenId)==msg.sender, "You dont have NFT token");
        return TOKEN_URI;
    }

    modifier userExists() {
        require(bytes(userProfiles[msg.sender].name).length != 0, "User does not exist");
        _;
    }

    function registerUser(string memory _name, string memory _bio, string memory _picture) public {
        require(bytes(userProfiles[msg.sender].name).length == 0, "User already registered");
        userProfiles[msg.sender] = UserProfile(_name, _bio, _picture, false);
        emit UserRegistered(msg.sender, _name, _bio, _picture);
    }

    function connectWallet() public userExists {
        require(!userProfiles[msg.sender].walletConnected, "Wallet already connected");
        userProfiles[msg.sender].walletConnected = true;
        emit WalletConnected(msg.sender);
    }

    function getUserInfo(address _user) public view returns (string memory, string memory, string memory, bool) {
        UserProfile memory profile = userProfiles[_user];
        return (profile.name, profile.bio, profile.picture, profile.walletConnected);
    }

    function checkReward(address _user) private userExists {
        if (subscriberCount[_user] >= 5) {
            mintNft();
        }
    }

    function getSubscribers(address _user) public view returns (address[] memory) {
        return subscriptions[_user];
    }

    function getSubscriberCount(address _user) public view returns (uint256) {
        return subscriberCount[_user];
    }

    function sendSubscriptionRequest(address _to) public userExists {
        require(_to != msg.sender, "Cannot send subscription request to yourself");
        require(!findSub(_to), "Cannot send subscription request if already subscribed or in the waitlist");

        subscriptionRequests[_to].push(msg.sender);
        emit SubscriptionRequestSent(msg.sender, _to);
    }

    function findSub(address _to) private view returns (bool) {
        address[] storage subs = subscriptions[_to];
        for (uint256 i = 0; i < subs.length; i++) {
            if (subs[i] == msg.sender) {
                return true; // Already subscribed
            }
        }

        address[] storage subRequests = subscriptionRequests[_to];
        for (uint256 i = 0; i < subRequests.length; i++) {
            if (subRequests[i] == msg.sender) {
                return true; // In the waitlist
            }
        }

        return false;
    }

    function acceptSubscriptionRequest(address _from) public userExists {
        int256 subId = findSubscriptionRequest(_from);
        require(subId != -1, "No subscription request from this address");

        // Set the subscription request to be deleted to a sentinel value (e.g., address(0))
        subscriptionRequests[msg.sender][uint256(subId)] = address(0);

        subscriptions[msg.sender].push(_from);
        subscriberCount[msg.sender]++;
        emit SubscriptionAccepted(_from, msg.sender);
        checkReward(msg.sender);
    }

    function findSubscriptionRequest(address _from) private view returns (int256) {
        address[] storage senderRequests = subscriptionRequests[msg.sender];
        for (uint256 i = 0; i < senderRequests.length; i++) {
            if (senderRequests[i] == _from) {
                return int256(i);
            }
        }
        return -1;
    }

    function getSubscriptionRequests() public view returns (address[] memory) {
       return subscriptionRequests[msg.sender];
    }
}
