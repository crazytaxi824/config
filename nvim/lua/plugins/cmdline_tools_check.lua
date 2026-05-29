-- 检查是否有 'make' 的能力.
local required_deps = { "make", "gcc", }


-- 专门用于获取 Linux 发行版 ID 的通用 Lua 函数
local function get_linux_distro()
  local f = io.open("/etc/os-release", "r")
  if not f then return "unknown" end

  local distro_id = "unknown"
  for line in f:lines() do
    -- 寻找类似 ID=ubuntu 或 ID="centos" 的行
    local match = line:match("^ID=(.+)$")
    if match then
      -- 移除可能存在的双引号
      distro_id = match:gsub('"', "")
      break
    end
  end
  f:close()
  return distro_id
end


for _, tool in ipairs(required_deps) do
  if vim.fn.executable(tool) == 0 then
    if jit.os == 'OSX' then
      vim.notify("run `$ xcode-select --install` to install cmdline tools in MacOS", vim.log.levels.WARN)
    elseif jit.os == 'Linux' then
      local distro = get_linux_distro()
      local install_cmd = ""

      -- 根据不同的发行版定制提示文本
      if distro == "ubuntu" or distro == "debian" then
        install_cmd = "sudo apt update && sudo apt install -y build-essential"
      elseif distro == "centos" or distro == "rhel" or distro == "rocky" then
        install_cmd = "sudo dnf groupinstall -y \"Development Tools\""
      elseif distro == "fedora" then
        install_cmd = "sudo dnf groupinstall -y \"Development Tools\""
      elseif distro == "arch" or distro == "manjaro" then
        install_cmd = "sudo pacman -S --needed base-devel"
      else
        install_cmd = "[please install make, gcc, unzip based on your system]"
      end

      vim.notify(string.format("run `$ %s` to install cmdline tools in %s", install_cmd, distro), vim.log.levels.WARN)
    else
      vim.notify(string.format("cmdline tool `make` is missing in %s", jit.os), vim.log.levels.WARN)
    end

    break
  end
end



