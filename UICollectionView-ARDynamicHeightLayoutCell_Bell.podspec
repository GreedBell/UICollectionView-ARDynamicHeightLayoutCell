Pod::Spec.new do |s|
  s.name         = "UICollectionView-ARDynamicHeightLayoutCell_Bell"
  s.version      = "1.0.4"
  s.summary      = "Automatically UICollectionViewCell size calculating."

  s.description  = <<-DESC
                   A longer description of UICollectionView-ARDynamicHeightLayoutCell in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/GreedBell/UICollectionView-ARDynamicHeightLayoutCell"
  s.license      = "MIT"
  s.authors            = { "August" => "liupingwei30@gmail.com","Bell" => "bell@greedlab.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/GreedBell/UICollectionView-ARDynamicHeightLayoutCell.git", :tag => s.version }
  s.source_files  = "UICollectionView+ARDynamicHeightLayoutCell", "UICollectionView+ARDynamicHeightLayoutCell/**/*.{h,m}"
  s.exclude_files = "UICollectionView+ARDynamicHeightLayoutCell/Exclude"
  s.frameworks = "UIKit", "Foundation"
end
