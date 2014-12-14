
define(
    [
        //System includes
        "angular",

        //Custom includes
        "pages/js/restapi"
    ],

    function (angular)
    {
        return angular.module
        (
            "uiNavbarModule",
            [
                "RestApiModule"
            ]
        )

        .directive
        (
            'uiNavbar',
            [
                function()
                {
                    return {
                        restrict: 'E',
                        scope: true,
                        replace: true,
                        templateUrl: 'blocks/navbar/navbar.html',
                        controller:
                        [
                            "$scope",
                            "$state",
                            "restapi",
                            function($scope, $state, restapi)
                            {
                                $scope.state = $state;
                                $scope.restapi = restapi;
                            }
                        ]
                    };
                }
            ]
        )
    }
);
