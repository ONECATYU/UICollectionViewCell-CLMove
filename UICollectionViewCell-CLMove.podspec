
Pod::Spec.new do |s|
  s.name         = "UICollectionViewCell-CLMove"
  s.version      = "0.0.2"
  s.summary      = "一行代码,使collectionView具有移动的能力."
  s.description  = <<-DESC
                    * 一行代码,使collectionView具有移动的能力.
                    * 集成使用方便
                   DESC
  s.homepage     = "https://github.com/ONECATYU/UICollectionViewCell-CLMove"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "ONECATYU" => "786910875@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/ONECATYU/UICollectionViewCell-CLMove.git", :tag => s.version.to_s }
  s.source_files  = "UICollectionViewCell+CLMove/**/*.{h,m}"
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true

end
