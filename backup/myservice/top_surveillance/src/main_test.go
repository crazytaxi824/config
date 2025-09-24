package main_test

import (
	"regexp"
	"strings"
	"testing"
)

func TestSplit(t *testing.T) {
	str := "123  33232    4u893"
	sp := strings.Fields(str)
	for _, v := range sp {
		t.Log(v)
	}
}

func TestParseInt(t *testing.T) {
	str := "273M"
	re := regexp.MustCompile(`[KMG]`)
	// re := regexp.MustCompile(`^\d+\w[\+-]?`)
	match := re.FindString(str)
	if match != "" {
		t.Log(match)
	} else {
		t.Log("未找到匹配的数字")
	}
}

func TestParseWord(t *testing.T) {
	str := "273M"
	re := regexp.MustCompile(`[KMG]`)
	loc := re.FindStringIndex(str)
	t.Log(loc)

	t.Log(str[loc[0]] == 'M')
	t.Log('M')
}

func TestBinary(t *testing.T) {
	t.Log(1<<20 == 1024*1024)
	t.Log(1 << 20)
	t.Log(1024 * 1024)
	t.Log(10 * 1 << 20)
}
