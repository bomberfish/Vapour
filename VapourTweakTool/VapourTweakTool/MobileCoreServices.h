// bomberfish
// MobileCoreServices.h – QuickSign
// created on 2025-05-06
#ifndef LaunchServicesPrivate_h
#define LaunchServicesPrivate_h
@import Foundation;
//@import UIKit;
NS_ASSUME_NONNULL_BEGIN
@interface LSBundleProxy: NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic) NSURL* dataContainerURL;
-(NSString*)localizedName;
@end

@interface LSPlugInKitProxy : LSBundleProxy
@property (nonatomic,readonly) NSString* pluginIdentifier;
@property (nonatomic,readonly) NSDictionary * pluginKitDictionary;
+ (instancetype)pluginKitProxyForIdentifier:(NSString*)arg1;
@end

@interface LSApplicationProxy : LSBundleProxy
@property (readonly, nonatomic) NSString *applicationType;
@property (getter=isBetaApp, readonly, nonatomic) BOOL betaApp;
@property (getter=isDeletable, readonly, nonatomic) BOOL deletable;
@property (getter=isRestricted, readonly, nonatomic) BOOL restricted;
@property (getter=isContainerized, readonly, nonatomic) BOOL containerized;
@property (getter=isAdHocCodeSigned, readonly, nonatomic) BOOL adHocCodeSigned;
@property (getter=isAppStoreVendable, readonly, nonatomic) BOOL appStoreVendable;
@property (getter=isLaunchProhibited, readonly, nonatomic) BOOL launchProhibited;
@property (nonatomic, readonly) NSString *canonicalExecutablePath API_AVAILABLE(ios(10.3));
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *vendorName   API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly) NSString *itemName     API_AVAILABLE(ios(7.1));
@property (nonatomic, readonly) NSDate *registeredDate API_AVAILABLE(ios(9.0));
@property (nonatomic, readonly) NSString *sourceAppIdentifier API_AVAILABLE(ios(8.2));
@property (nonatomic, readonly) NSArray <NSNumber *> *deviceFamily  API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly) NSArray <NSString *> *activityTypes API_AVAILABLE(ios(10.0));
@property (readonly, nonatomic) NSSet <NSString *> *claimedURLSchemes;
@property (readonly, nonatomic) NSString *teamID;
@property (copy, nonatomic) NSString *sdkVersion;
@property (readonly, nonatomic) NSDictionary <NSString *, id> *entitlements;
@property (readonly, nonatomic) NSURL* _Nullable bundleContainerURL;
+ (instancetype)applicationProxyForIdentifier:(NSString*)identifier;
@property NSURL* bundleURL;
@property NSString* bundleType;
@property (nonatomic,readonly) NSDictionary* groupContainerURLs;
@property (nonatomic,readonly) NSArray* plugInKitPlugins;
@property (getter=isInstalled,nonatomic,readonly) BOOL installed;
@property (getter=isPlaceholder,nonatomic,readonly) BOOL placeholder;
- (NSString *)applicationIdentifier;
- (NSURL *)containerURL;
- (NSURL *)bundleURL;
- (NSString *)localizedName;
- (NSData *)iconDataForVariant:(id)variant;
- (NSData *)iconDataForVariant:(id)variant withOptions:(id)options;
- (NSArray<LSPlugInKitProxy *> *)plugInKitPlugins;
- (NSData *)primaryIconDataForVariant:(int)variant;
@end

@interface LSPlugInKitProxy ()
- (LSApplicationProxy *)containingBundle;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype) defaultWorkspace;
- (NSArray <LSApplicationProxy *> *)allInstalledApplications;
- (NSArray <LSApplicationProxy *> *)allApplications;
- (NSArray <LSPlugInKitProxy *> *) installedPlugins;
- (BOOL)openApplicationWithBundleID:(NSString *)arg0 ;
- (BOOL)uninstallApplication:(NSString *)arg0 withOptions:(_Nullable id)arg1 error:(NSError **)arg2 usingBlock:(_Nullable id)arg3;
- (BOOL)registerApplicationDictionary:(NSDictionary*)dict;
- (BOOL)unregisterApplication:(id)arg1;
- (BOOL)_LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)arg1 internal:(BOOL)arg2 user:(BOOL)arg3;
- (BOOL)uninstallApplication:(NSString*)arg1 withOptions:(id)arg2;
- (void)enumerateApplicationsOfType:(NSUInteger)type block:(void (^)(LSApplicationProxy*))block;
- (NSProgress*)installProgressForBundleID:(id)arg1 makeSynchronous:(unsigned char)arg2;
@end

@interface LSEnumerator : NSEnumerator
@property (nonatomic,copy) NSPredicate * predicate;
+ (instancetype)enumeratorForApplicationProxiesWithOptions:(NSUInteger)options;
@end

@interface MCMContainer : NSObject
+ (id)containerWithIdentifier:(id)arg1 createIfNecessary:(BOOL)arg2 existed:(BOOL*)arg3 error:(_Nullable id*_Nullable)arg4;
@property (nonatomic,readonly) NSURL * url;
@end

@interface MCMDataContainer : MCMContainer
@end

@interface MCMAppDataContainer : MCMDataContainer
@end

@interface MCMAppContainer : MCMContainer
@end

@interface MCMPluginKitPluginDataContainer : MCMDataContainer
@end
#endif /* LaunchServicesPrivate_h */
NS_ASSUME_NONNULL_END
