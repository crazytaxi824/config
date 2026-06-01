### curl -o font-sarasa-gothic.rb https://raw.githubusercontent.com/Homebrew/homebrew-cask/e3fbdccd0e0c47afe388a16c33b88c2d3269b20c/Casks/font/font-s/font-sarasa-gothic.rb
### brew tap-new mylocal/repo
### mkdir -p $(brew --repo mylocal/repo)/Casks
### cp font-sarasa-gothic.rb $(brew --repo mylocal/repo)/Casks
### brew install mylocal/repo/font-sarasa-gothic
### brew trust --cask mylocal/repo/font-sarasa-gothic

cask "font-sarasa-gothic" do
  version "1.0.37"
  sha256 "bda22d32a7cb6585fadd412bb68c008e75e88375a533347bc659c53a478ff0d2"

  url "https://github.com/be5invis/Sarasa-Gothic/releases/download/v#{version}/Sarasa-SuperTTC-#{version}.7z"
  name "Sarasa Gothic"
  name "更纱黑体"
  name "更紗黑體"
  name "更紗ゴシック"
  name "사라사고딕"
  homepage "https://github.com/be5invis/Sarasa-Gothic"

  font "Sarasa-SuperTTC.ttc"

  # No zap stanza required
end
