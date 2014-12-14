
require.config
(
    {
        baseUrl: "",
        paths:
        {
            angular: "/libs/js/min/angular.min",
            angularAnimate: "/libs/js/min/angular-animate.min",
            storeJson2: "/libs/js/store_json2",
            angularUIRoute: "/libs/js/min/angular-ui-router.min",
            angularSanitize: "/libs/js/min/angular-sanitize.min",
            angularCookies: "/libs/js/min/angular-cookies.min",
            angularResource: "/libs/js/min/angular-resource.min",
            angularUtils: '/libs/js/min/ui-utils.min',
            anguComplete: '/libs/js/angucomplete',
            domReady: '/libs/js/domReady',
            jQuery: '/libs/js/min/jquery-2.1.1.min',
            jQueryUi: '/libs/js/jquery-ui.min',
            bootstrap: '/libs/js/min/bootstrap.min',
            bootstrapUi: '/libs/js/min/ui-bootstrap-tpls-0.11.0.min',
            angularDAD: '/libs/js/angular-dragdrop',
            angularFilters: '/libs/js/angular-filter',
            chart: '/libs/js/min/Chart.min',
            chartjsDirective: '/libs/js/chartjs-directive'
        },
        shim:
        {
            angular:
            {
                exports: "angular",
                deps: ["jQuery"]
            },
            angularUIRoute: { deps: ["angular"] },
            angularAnimate: { deps: ["angular"] },
            angularSanitize: { deps: ["angular"] },
            angularCookies: { deps: ["angular"] },
            angularResource: { deps: ["angular"] },
            angularUtils: { deps: ["angular"] },
            anguComplete: { deps: ["angular"] },
            bootstrap:  { deps: ["jQuery"] },
            bootstrapUi: { deps: ["bootstrap", "angular"] },
            jQueryUi: { deps: ["jQuery"] },
            angularDAD: { deps: ["jQueryUi", "angular"] },
            chartjsDirective: {deps: ["chart","angular"]}
        }
    }
);

require
(
    [
        //System includes
        "angular",
        "domReady",

        //Custom includes
        "pages/js/casd"
    ],

    function(angular, domReady, casd)
    {
        domReady
        (
            function()
            {
                angular.bootstrap(document, [casd.name]);
            }
        );
    }
);

