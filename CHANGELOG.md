# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Next]
### Added
### Changed
### Fixed

## [0.3.4]
### Fixed
- cover multiple possible returns types of display_class

## [0.3.3]
### Fixed
- Fix unwrap_class_name, it was wrongly expecting an instance not a class.

## [0.3.2]
### Added
- Implement a custom version of Sidekiq's display\_class\_name that fix an issues with ActiveJob > 6 when the job's class is passed as class not String
- Limit support up to Sidekiq < 6. 

## [0.3.1]
### Fixed
- class name calculation needs to filter out unsupported characters by instrumental

## [0.3.0]
### Fixed
- class name calculation now uses Sidekiq's display\_class\_name to support ActiveJob jobs

