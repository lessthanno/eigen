#import "ARSwitchBoard.h"
#import "ARSwitchboard+Eigen.h"
#import "AROptions.h"
#import "ARRouter.h"
#import "ArtsyAPI.h"
#import "ArtsyAPI+Profiles.h"
#import "ARTopMenuViewController.h"
#import "ARFavoritesViewController.h"
#import "ARProfileViewController.h"
#import "ARArtistViewController.h"
#import "ARBrowseCategoriesViewController.h"
#import "ARArtworkSetViewController.h"
#import "ARExternalWebBrowserViewController.h"
#import "ARGeneViewController.h"
#import "ARInternalMobileWebViewController.h"
#import "ARProfileViewController.h"
#import "ARShowViewController.h"
#import "ARFairViewController.h"
#import "ARFairArtistViewController.h"
#import "ARFairGuideContainerViewController.h"
#import "ARTopMenuNavigationDataSource.h"


@interface ARSwitchBoard (Tests)
- (NSURL *)resolveRelativeUrl:(NSString *)path;
- (id)routeInternalURL:(NSURL *)url fair:(Fair *)fair;
- (void)openURLInExternalService:(NSURL *)url;
- (void)updateRoutes;

@property (nonatomic, strong) Aerodramus *echo;

@end


@interface ARProfileViewController (Tests)
- (void)showViewController:(UIViewController *)viewController;
@end


@interface ARTopMenuViewController (Tests)
@property (nonatomic, readonly) ARTopMenuNavigationDataSource *navigationDataSource;
@end


@interface ARTopMenuNavigationDataSource (Tests)
@property (nonatomic, readonly) ARNavigationController *notificationsNavigationController;
@end

SpecBegin(ARSwitchBoard);

__block ARSwitchBoard *switchboard;

describe(@"ARSwitchboard", ^{

    beforeEach(^{
        switchboard = [[ARSwitchBoard alloc] init];
        [switchboard updateRoutes];
    });

    describe(@"resolveRelativeUrl", ^{
        beforeEach(^{
            [AROptions setBool:false forOption:ARUseStagingDefault];
            [ARRouter setup];
        });

        it(@"resolves absolute artsy.net url", ^{
            NSString *resolvedUrl = [[switchboard resolveRelativeUrl:@"http://artsy.net/foo/bar"] absoluteString];
            expect(resolvedUrl).to.equal(@"http://artsy.net/foo/bar");
        });

        it(@"resolves absolute external url", ^{
            NSString *resolvedUrl = [[switchboard resolveRelativeUrl:@"http://example.com/foo/bar"] absoluteString];
            expect(resolvedUrl).to.equal(@"http://example.com/foo/bar");
        });

        it(@"resolves relative url", ^{
            NSString *resolvedUrl = [[switchboard resolveRelativeUrl:@"/foo/bar"] absoluteString];
            expect(resolvedUrl).to.equal(@"https://m.artsy.net/foo/bar");
        });
    });

    describe(@"loadURL", ^{
        __block id switchboardMock;

        before(^{
            switchboardMock = [OCMockObject partialMockForObject:switchboard];
        });

        describe(@"with internal url", ^{
            it(@"routes internal urls correctly", ^{
                NSURL *internalURL = [[NSURL alloc] initWithString:@"http://artsy.net/some/path"];
                [[switchboardMock expect] routeInternalURL:internalURL fair:nil];
                [switchboard loadURL:internalURL];
                [switchboardMock verify];
            });
        });

        describe(@"with non http schemed url", ^{
            it(@"does not load an internal view", ^{
                [[switchboardMock stub] openURLInExternalService:OCMOCK_ANY];

                NSURL *externalURL = [[NSURL alloc] initWithString:@"mailto:email@mail.com"];
                [[switchboardMock reject] routeInternalURL:OCMOCK_ANY fair:nil];
                [switchboard loadURL:externalURL];
                [switchboardMock verify];
            });

            it(@"does not load browser", ^{
                id sharedAppMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                [[sharedAppMock reject] openURL:OCMOCK_ANY];

                NSURL *internalURL = [[NSURL alloc] initWithString:@"mailto:email@mail.com"];
                [switchboard loadURL:internalURL];
                [sharedAppMock verify];
            });

            it(@"opens with the OS for non-http links", ^{
                NSURL *internalURL = [[NSURL alloc] initWithString:@"tel:111111"];
                [[switchboardMock expect] openURLInExternalService:OCMOCK_ANY];

                [switchboard loadURL:internalURL];
                [switchboardMock verify];
            });
        });

        it(@"handles breaking out of the eigen routing sandbox when needed", ^{
            id sharedAppMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[sharedAppMock expect] openURL:OCMOCK_ANY];

            NSURL *internalURL = [[NSURL alloc] initWithString:@"http://mysitethatmustbeopenedinsafari.com?eigen_escape_sandbox=true"];
            [switchboard loadURL:internalURL];
            
            [sharedAppMock verify];
        });

        describe(@"with applewebdata urls", ^{
            it(@"does not load browser", ^{
                NSURL *internalURL = [[NSURL alloc] initWithString:@"applewebdata://EF86F744-3F4F-4732-8A4B-3E5E94D6D7DA/some/path"];
                id sharedAppMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                [[sharedAppMock reject] openURL:OCMOCK_ANY];
                [switchboard loadURL:internalURL];
                [sharedAppMock verify];

            });

            it(@"routes internal urls", ^{
                NSURL *internalURL = [[NSURL alloc] initWithString:@"applewebdata://EF86F744-3F4F-4732-8A4B-3E5E94D6D7DA/some/path"];
                [[switchboardMock expect] routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/some/path"] fair:nil];
                [switchboard loadURL:internalURL];
                [switchboardMock verify];
            });
        });

        it(@"loads web view for external urls", ^{
            it(@"loads browser", ^{
                NSURL *externalURL = [[NSURL alloc] initWithString:@"http://google.com"];
                id viewController = [switchboard loadURL:externalURL];
                expect([viewController isKindOfClass:[ARExternalWebBrowserViewController class]]).to.beTruthy();

            });

            it(@"does not route url", ^{
                NSURL *externalURL = [[NSURL alloc] initWithString:@"http://google.com"];
                [[switchboardMock reject] routeInternalURL:OCMOCK_ANY fair:nil];
                [switchboard loadURL:externalURL];
                [switchboardMock verify];
            });
        });
    });

    describe(@"adding a new route", ^{
        it(@"supports adding via the register method", ^{
            UIViewController *newVC = [[UIViewController alloc] init];
            id subject = [switchboard loadPath:@"thingy"];
            // Yeah, so, we have this awkward catch-all profile class for any route
            // thus if the route isn't registered, it'll go to that
            expect(subject).to.beAKindOf(ARProfileViewController.class);
            [switchboard registerPathCallbackAtPath:@"/thingy" callback:^id _Nullable(NSDictionary * _Nullable parameters) {
                return newVC;
            }];
            expect([switchboard loadPath:@"thingy"]).to.equal(newVC);
        });
    });

    describe(@"adding a new domain", ^{
        it(@"supports adding via the register method", ^{
            UIViewController *newVC = [[UIViewController alloc] init];
            [switchboard registerPathCallbackForDomain:@"orta.artsy.net" callback:^id _Nullable(NSURL * _Nonnull url) {
                return newVC;
            }];

            expect([switchboard loadURL:[NSURL URLWithString:@"https://orta.artsy.net/me/thing"]]).to.equal(newVC);
        });

        it(@"sends the URL in to the callback for the URL routing", ^{
            UIViewController *newVC = [[UIViewController alloc] init];
            __block NSString *path = nil;
            [switchboard registerPathCallbackForDomain:@"orta.artsy.net" callback:^id _Nullable(NSURL * _Nonnull url) {
                path = url.path;
                return newVC;
            }];

            [switchboard loadURL:[NSURL URLWithString:@"https://orta.artsy.net/me/thing"]];
            expect(path).to.equal(@"/me/thing");
        });
    });


    describe(@"routeInternalURL", ^{
        it(@"routes profiles", ^{
            // See aditional tests for profile routing below.
            NSURL *profileURL = [[NSURL alloc] initWithString:@"http://artsy.net/myprofile"];
            id subject = [switchboard routeInternalURL:profileURL fair:nil];
            expect(subject).to.beKindOf(ARProfileViewController.class);

        });

        it(@"routes artists", ^{
            id subject = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/artist/artistname"] fair:nil];
            expect(subject).to.beKindOf(ARArtistViewController.class);
        });

        it(@"routes artists in a gallery context on iPad", ^{
            [ARTestContext useDevice:ARDeviceTypePad :^{
                // Now we're in a different context, need to recreate switchboard
                switchboard = [[ARSwitchBoard alloc] init];
                [switchboard updateRoutes];

                id viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/some-gallery/artist/artistname"] fair:nil];
                expect(viewController).to.beKindOf(ARArtistViewController.class);
            }];
        });

        it(@"does not route artists in a gallery context on iPhone", ^{
            [ARTestContext useDevice:ARDeviceTypePhone5 :^{
                switchboard = [[ARSwitchBoard alloc] init];
                id viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/some-gallery/artist/artistname"] fair:nil];
                expect(viewController).to.beKindOf([ARInternalMobileWebViewController class]);
            }];
        });

        it(@"routes shows", ^{
            id viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/show/show-id"] fair:nil];
            expect(viewController).to.beKindOf(ARShowViewController.class);
        });

        context(@"fairs", ^{

            context(@"on iphone", ^{
                before(^{
                    [ARTestContext stubDevice:ARDeviceTypePhone5];
                    switchboard = [[ARSwitchBoard alloc] init];
                    [switchboard updateRoutes];
                });

                after(^{
                    [ARTestContext stopStubbing];
                });

                it(@"routes fair guide", ^{
                    Fair *fair = [OCMockObject mockForClass:[Fair class]];
                    id viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/fair-id/for-you"] fair:fair];
                    expect(viewController).to.beKindOf(ARFairGuideContainerViewController.class);
                });

                it(@"routes fair artists", ^{
                    Fair *fair = [OCMockObject mockForClass:[Fair class]];
                    id viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"/the-armory-show/browse/artist/artist-id"] fair:fair];
                    expect(viewController).to.beKindOf(ARFairArtistViewController.class);
                });

                it(@"forwards fair views to martsy for non-native views", ^{
                    Fair *fair = [OCMockObject mockForClass:[Fair class]];
                    ARInternalMobileWebViewController *viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"/the-armory-show/browse/artists"] fair:fair];
                    expect(viewController.fair).to.equal(fair);
                    expect(viewController).to.beKindOf(ARInternalMobileWebViewController.class);
                });
            });

            context(@"on ipad", ^{
                before(^{
                    [ARTestContext stubDevice:ARDeviceTypePad];
                    switchboard = [[ARSwitchBoard alloc] init];
                });

                after(^{
                    [ARTestContext stopStubbing];
                });

                it(@"doesn't route fair guide", ^{
                    Fair *fair = [OCMockObject mockForClass:[Fair class]];

                    ARInternalMobileWebViewController *viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/fair-id/for-you"] fair:fair];
                    expect(viewController).to.beKindOf([ARInternalMobileWebViewController class]);
                    expect(viewController.fair).to.equal(fair);
                });

                it(@"doesn't route fair artists", ^{
                    Fair *fair = [OCMockObject mockForClass:[Fair class]];

                    ARInternalMobileWebViewController *viewController = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"/the-armory-show/browse/artist/artist-id"] fair:fair];
                    expect(viewController).to.beKindOf([ARInternalMobileWebViewController class]);
                    expect(viewController.fair).to.equal(fair);
                });
            });
        });

        it(@"routes artworks", ^{
            id subject = [switchboard routeInternalURL:[NSURL URLWithString:@"http://artsy.net/artwork/artworkID"] fair:nil];
            expect(subject).to.beKindOf(ARArtworkSetViewController.class);
        });

        it(@"routes artworks and retains fair context", ^{
            Fair *fair = [Fair modelWithJSON:@{}];
            ARArtworkSetViewController *subject = [switchboard routeInternalURL:[[NSURL alloc] initWithString:@"http://artsy.net/artwork/artworkID"] fair:fair];
            expect(subject.fair).to.equal(fair);
        });

        it(@"routes genes", ^{
            id subject = [switchboard routeInternalURL:[NSURL URLWithString:@"http://artsy.net/gene/surrealism"] fair:nil];
            expect(subject).to.beAKindOf(ARGeneViewController.class);
        });

        /// As the class is in swift-world, lets not complicate this by bridging when it's not important
        it(@"routes live auctions", ^{
            switchboard = [[ARSwitchBoard alloc] init];
            [switchboard updateRoutes];

            id subject = [switchboard loadURL:[NSURL URLWithString:@"https://live.artsy.net"]];
            NSString *classString = NSStringFromClass([subject class]);
            expect(classString).to.contain(@"LiveAuctionViewController");
        });

        it(@"routes auctions", ^{
            switchboard = [[ARSwitchBoard alloc] init];
            [switchboard updateRoutes];

            id subject = [switchboard loadPath:@"/auction/myauctionthing"];
            NSString *classString = NSStringFromClass([subject class]);
            expect(classString).to.contain(@"AuctionViewController");
        });

        it(@"can not route to native auctions when echo has a feature called 'DisableNativeAuctions'", ^{
            switchboard = [[ARSwitchBoard alloc] init];
            [switchboard updateRoutes];
            ArtsyEcho *echo = [[ArtsyEcho alloc] init];
            echo.features = @{ @"DisableNativeAuctions" : [[Feature alloc] initWithName:@"" state:@1] };
            switchboard.echo = echo;

            id subject = [switchboard loadPath:@"/auction/myauctionthing"];
            NSString *classString = NSStringFromClass([subject class]);
            expect(classString).toNot.contain(@"AuctionViewController");
        });
    });

    describe(@"routeProfileWithID", ^{
        __block id mockProfileVC;

        before(^{
            mockProfileVC = [OCMockObject mockForClass:[ARProfileViewController class]];
        });

        describe(@"with a non-fair profile", ^{
        });

        describe(@"with a fair profile", ^{
            beforeEach(^{
                [OHHTTPStubs stubJSONResponseAtPath:@"/api/v1/profile/myfairprofile" withResponse:@{
                                                                                                    @"id" : @"myfairprofile",
                                                                                                    @"owner": @{ @"default_fair_id" : @"armory-show-2013" },
                                                                                                    @"owner_type" : @"FairOrganizer" }];
            });

            it(@"internally does not load martsy", ^{
                [[mockProfileVC reject] showViewController:[OCMArg checkForClass:[ARInternalMobileWebViewController class]]];
                [switchboard routeProfileWithID:@"myfairprofile"];
            });

            it(@"routes fair profiles specially", ^{
                [[mockProfileVC expect] showViewController:[OCMArg checkForClass:[ARFairViewController class]]];
                [switchboard routeProfileWithID:@"myfairprofile"];
            });
        });
    });
});

SpecEnd;
