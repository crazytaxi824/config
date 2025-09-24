package main

import (
	"bufio"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"
)

var (
	logfile     *os.File                      // cache log file handler
	home        string                        // HOME dir
	logfilename          = "top_surveillance" // filename under $HOME

	maxCPU      float64 = 80               // (n)%
	maxFilesize int64   = 10 * 1 << 20     // (n)MB
	sleep               = 30 * time.Second // (n)s
)

func main() {
	log.SetFlags(log.Llongfile)

	var err error
	home, err = os.UserHomeDir()
	if err != nil {
		log.Println(err)
		return
	}

	for {
		// top logging command
		// NOTE: 可以使用 `COLUMNS=999 ps -p 527 -o pid=,command=` 获取command & args
		cmd := exec.Command("top", "-l", "2", "-n", "5", "-s", "1", "-o", "cpu", "-stats", "cpu,mem,pid,command")
		cmd.Env = []string{"COLUMNS=999"} // 防止 top 打印不全
		stdout, err := cmd.StdoutPipe()
		if err != nil {
			log.Println(err)
			return
		}

		if err = cmd.Start(); err != nil {
			log.Println(err)
			return
		}

		// parse data & write log file
		if err = parseTopData(stdout); err != nil {
			log.Println(err)
			return
		}

		// Wait for the command to finish
		if err = cmd.Wait(); err != nil {
			log.Println(err)
			return
		}

		time.Sleep(sleep)
	}
}

func parseTopData(stdout io.Reader) error {
	// open log file
	var err error
	logfile, err = os.OpenFile(filepath.Join(home, logfilename+".log"), os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0600)
	if err != nil {
		log.Println(err)
		return err
	}
	defer logfile.Close()

	// cache time stamp
	var timeCache string

	// Create a scanner to read the output line by line
	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		txt := scanner.Text()

		// parse date & time
		_, err = time.Parse("2006/01/02 15:04:05", txt)
		if err == nil {
			timeCache = txt // cache exec time
			continue
		}

		// parse & write data
		err = parseAndWriteFile(txt, timeCache)
		if err != nil {
			log.Println(err)
			return err
		}
	}

	// 这里是 scanner 的 error, 而不是 command 执行错误返回的 error.
	if err := scanner.Err(); err != nil {
		log.Println(err)
		return err
	}

	return nil
}

func parseAndWriteFile(txt, timeCache string) error {
	re := regexp.MustCompile(`^\d+.*$`)
	r := re.FindString(txt)
	if r == "" {
		return nil
	}

	strs := strings.Fields(txt)
	cpu, err := strconv.ParseFloat(strs[0], 64)
	if err != nil {
		log.Println(err)
		return err
	}

	// 当 cpu < n% 不记录
	if cpu < maxCPU {
		return nil
	}

	// NOTE: 使用 `ps -p pid -o command=` 获取 command fullpath & args
	cmd := exec.Command("ps", "-p", strs[2], "-o", "command=")
	ps, _ := cmd.Output() //nolint // pid=0 (kernel_task) 时会报错

	// write file
	content := "[" + timeCache + "] " + txt
	if len(ps) > 0 {
		content = content + " | " + string(ps)
	} else {
		content += "\n"
	}

	// NOTE: DEBUG
	// log.Println(content)

	_, err = logfile.WriteString(content)
	if err != nil {
		log.Println(err)
		return err
	}

	// check file size
	return checkFilesize()
}

func checkFilesize() error {
	// check file size
	fi, err := logfile.Stat()
	if err != nil {
		log.Println(err)
		return err
	}

	if fi.Size() > maxFilesize {
		// close old file handler
		err = logfile.Close()
		if err != nil {
			log.Println(err)
			return err
		}

		// move old file
		err = os.Rename(filepath.Join(home, logfilename+".log"),
			filepath.Join(home, logfilename+"_old.log"))
		if err != nil {
			log.Println(err)
			return err
		}

		// create a new file to write
		logfile, err = os.OpenFile(filepath.Join(home, logfilename+".log"),
			os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0600)
		if err != nil {
			log.Println(err)
			return err
		}
	}

	return nil
}
