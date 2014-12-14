
define(
    [
        //System includes
        "angular",

        //Custom includes
        "pages/js/restapi"
    ],

    function(angular)
    {
        return angular.module
        (
            "UserModule",
            [
                "RestApiModule"
            ]
        )

        .controller
        (
            "UserCtr",
            [
                "$scope",
                "user",
                "restapi",
                "$state",
                function($scope, user, restapi, $state)
                {
                    $scope.user = user;
                    $scope.change = function(form)
                    {
                        restapi.change(form.user_name, form.email, form.password, user.id).then
                        (
                            function () {
                                $state.go("user");
                            }
                        )
                    };
                    $scope.delete = function()
                    {
                        restapi.delete_user(user.id).then
                        (
                            function () {
                                $state.go("login");
                            }
                        )
                    };
                }
            ]
        )

        .factory
        (
            'UserProvider',
            [
                "restapi",
                function(restapi)
                {
                    var module = {};
                    module.resolver = function()
                    {
                        return restapi.current_user();
                    };
                    return module;
                }
            ]
        );
    }
);
