#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBActionRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistryImplementation;

@end

@implementation HUBManager

- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                         componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                               imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
                                iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                       defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                 prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
                  appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory
{
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(componentFallbackHandler != nil);
    
    self = [super init];
    
    if (self) {
        HUBComponentDefaults * const componentDefaults = [[HUBComponentDefaults alloc] initWithComponentNamespace:componentFallbackHandler.defaultComponentNamespace
                                                                                                    componentName:componentFallbackHandler.defaultComponentName
                                                                                                componentCategory:componentFallbackHandler.defaultComponentCategory];
        
        _connectivityStateResolver = connectivityStateResolver;
        _initialViewModelRegistry = [HUBInitialViewModelRegistry new];
        
        HUBFeatureRegistryImplementation * const featureRegistry = [HUBFeatureRegistryImplementation new];
        
        HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                                              iconImageResolver:iconImageResolver];
        
        HUBComponentRegistryImplementation * const componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler
                                                                                                                         componentDefaults:componentDefaults
                                                                                                                        JSONSchemaRegistry:JSONSchemaRegistry
                                                                                                                         iconImageResolver:iconImageResolver];
        
        HUBViewModelLoaderFactoryImplementation * const viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:featureRegistry
                                                                                                                                       JSONSchemaRegistry:JSONSchemaRegistry
                                                                                                                                 initialViewModelRegistry:_initialViewModelRegistry
                                                                                                                                        componentDefaults:componentDefaults
                                                                                                                                connectivityStateResolver:_connectivityStateResolver
                                                                                                                                        iconImageResolver:iconImageResolver
                                                                                                                         prependedContentOperationFactory:prependedContentOperationFactory
                                                                                                                          appendedContentOperationFactory:appendedContentOperationFactory
                                                                                                                               defaultContentReloadPolicy:defaultContentReloadPolicy];
        
        HUBActionRegistryImplementation * const actionRegistry = [HUBActionRegistryImplementation new];
        
        HUBViewControllerFactoryImplementation * const viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:viewModelLoaderFactory
                                                                                                                                              featureRegistry:featureRegistry
                                                                                                                                            componentRegistry:componentRegistry
                                                                                                                                     initialViewModelRegistry:_initialViewModelRegistry
                                                                                                                                       componentLayoutManager:componentLayoutManager
                                                                                                                                           imageLoaderFactory:imageLoaderFactory];
        
        _featureRegistry = featureRegistry;
        _componentRegistry = componentRegistry;
        _componentRegistryImplementation = componentRegistry;
        _actionRegistry = actionRegistry;
        _JSONSchemaRegistry = JSONSchemaRegistry;
        _viewModelLoaderFactory = viewModelLoaderFactory;
        _viewControllerFactory = viewControllerFactory;
    }
    
    return self;
}

#pragma mark - Accessor overrides

- (id<HUBComponentShowcaseManager>)componentShowcaseManager
{
    return self.componentRegistryImplementation;
}

@end

NS_ASSUME_NONNULL_END
