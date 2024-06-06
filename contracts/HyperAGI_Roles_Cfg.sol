pragma solidity ^0.8.0;

interface IHyperAGI_Roles_Cfg {
    function addAdmin(address account) external;

    function addSuperAdmin(address account) external;

    function addAdmin2(address account) external;

    function hasAdminRole(address account) external view returns (bool);

    function deleteAdmin(address account) external;
}
