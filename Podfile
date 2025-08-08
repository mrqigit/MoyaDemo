source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '16.0'

target 'MoyaDemo' do

  use_frameworks!

  pod 'Moya', '~> 15.0.0'
  pod 'SnapKit', '~> 5.7.1'

end

# 安装后钩子
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 统一设置部署目标
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      # 启用新构建系统
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
  end
end
