cd "$(mktemp -d)"
echo "2c3cb01e70f1d4a384944edf4bb940d8ba06e8bf8539f7cff90ee2e593b6ee14  ./shellcheck.rb" >> formulas.sha256sum
echo "db3e8d1230379f32710b11ee4f824eceafea16fbcf07f61a93da440f430cee67  ./shfmt.rb" >> formulas.sha256sum
echo "bedc61ae0d0ac33c5de9ebfa2ffb482059e194ab3ac34ff7f77ad904ebb5814f  ./swiftlint.rb" >> formulas.sha256sum
echo "b4ab76e6c0e76c33875478c2adaedfbebc07c624905a3403874bbd1a0b6b3828  ./swiftformat.rb" >> formulas.sha256sum
curl --proto "=https" --tlsv1.2 -sSf https://raw.githubusercontent.com/Homebrew/homebrew-core/716c0578846b23c2fbdf8315da9af8b6ca2c96aa/Formula/shellcheck.rb -o shellcheck.rb
curl --proto "=https" --tlsv1.2 -sSf https://raw.githubusercontent.com/Homebrew/homebrew-core/290a7cbdbc7ab4f5c52e82d014acbc530a71c765/Formula/shfmt.rb -o shfmt.rb
curl --proto "=https" --tlsv1.2 -sSf https://raw.githubusercontent.com/Homebrew/homebrew-core/f3394380d569634e6a751f7b49af12e9bf777c22/Formula/swiftlint.rb -o swiftlint.rb
curl --proto "=https" --tlsv1.2 -sSf https://raw.githubusercontent.com/Homebrew/homebrew-core/d8557ff95d1dd50d667521877771f72182e70219/Formula/swiftformat.rb -o swiftformat.rb
shasum --algorithm 256 --check formulas.sha256sum
brew reinstall --force-bottle ./shellcheck.rb
brew reinstall --force-bottle ./shfmt.rb
brew reinstall --force-bottle ./swiftlint.rb
brew reinstall --force-bottle ./swiftformat.rb
cd -