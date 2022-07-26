package app

import (
	"github.com/urfave/cli"
	"log"
	"os"
	"sort"
)

func New() *cli.App {
	app := &cli.App{
		Name:  "nidi",
		Usage: "A CLI to config your laptop as code",
	}
	app.Flags = []cli.Flag{
		&cli.BoolFlag{
			Name:  "debug",
			Usage: "enable debug",
		},
	}
	app.Commands = getCommands()

	sort.Sort(cli.FlagsByName(app.Flags))
	sort.Sort(cli.CommandsByName(app.Commands))

	app.Action = func(c *cli.Context) error {
		cli.ShowAppHelpAndExit(c, 0)
		return nil
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
	return app
}

func getCommands() []*cli.Command {
	return []*cli.Command{}
}
