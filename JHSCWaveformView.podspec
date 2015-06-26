Pod::Spec.new do |s|

  s.name         = "JHSCWaveformView"
  s.version      = "2.0.6"
  s.summary      = "A blazing fast customizable waveform view."

  s.description  = <<-DESC
		   A blazing fast customizable waveform view. Extract the audio section of an asset (which can be both video or audio) and display a waveform.
		   The SCWaveformView is optimized to do the less file read possible. When scrolling or displaying another part of the waveform, it will only read whatever it needs to render the new section.
		   It will cache the file data to avoid having to read sections that have been already computed. Furthermore, if it does have to read the file, it will read it by bigger segment to minimize the number of read operations next time the timeRange changes.
                   DESC

  s.homepage     = "https://github.com/jhays/JHSCWaveformView"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { "Simon CORSIN" => "simon@corsin.me", "JHays" => "orbosphere@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/jhays/JHSCWaveformView.git", :tag => "v2.0.6" }
  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files = 'Sources/*.h'
  s.requires_arc = true
  s.subspec 'Chameleon' do |c|
    c.dependency 'ChameleonFramework'
    c.dependency 'UIColor-Crayola'
    c.dependency 'UIColor-Pantone'
  end
end
