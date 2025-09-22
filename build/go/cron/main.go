package main

import (
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"bufio"
	"io"
	"github.com/go-co-op/gocron/v2"

	"github.com/11notes/go/util"
)

const SCHEDULE = "CONFIGARR_SCHEDULE"

var (
	PID int = 0
)

func main(){
	// catch syscalls
	signalChannel := make(chan os.Signal, 1)
	signal.Notify(signalChannel, syscall.SIGTERM, syscall.SIGSTOP, syscall.SIGINT)
	go func() {
		<- signalChannel
		os.Exit(0)
	}()

	// check arguments
	if(len(os.Args) > 1){
		args := os.Args[1:]
		switch args[0] {
			case "--ping":
				_, err := os.FindProcess(PID)
				if err != nil{
					os.Exit(1)
				}
				os.Exit(0)
		}
	}else{
		// set schedule
		if _, ok := os.LookupEnv(SCHEDULE); ok {
			util.Log("inf", "setting schedule: " + os.Getenv(SCHEDULE))
			scheduler, err := gocron.NewScheduler()
			if err != nil {
				util.Log("err", "cron error: " + err.Error())
			}
			_, err = scheduler.NewJob(gocron.CronJob(os.Getenv(SCHEDULE), false), gocron.NewTask(run))
			if err != nil {
				util.Log("err", "cron error: " + err.Error())
			}
			scheduler.Start()
		}

		// execute
		run()

		// wait
		select {}
	}
}

func run(){
	cmd := exec.Command("/usr/local/bin/node", "/opt/configarr/bundle.cjs")
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid:true}

	stdout, _ := cmd.StdoutPipe()
	stderr, _ := cmd.StderrPipe()

	go func() {
		stdoutScanner := bufio.NewScanner(io.MultiReader(stdout,stderr))
		for stdoutScanner.Scan() {
			stdout := stdoutScanner.Text()
			util.Log("inf", stdout)
		}
	}()

	// start process
	err := cmd.Start()
	PID = cmd.Process.Pid
	util.Log("inf", "starting configarr sync process")
	if err != nil {
		util.Log("err", "sync error: " + err.Error())
	}else{
		err = cmd.Wait()
		if err != nil {
			util.Log("err", "sync error: " + err.Error())
		}else{
			util.Log("inf", "sync complete")
		}
	}
}