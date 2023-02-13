package route

import (
	"errors"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"github.com/labstack/echo"
)

const IMAGEPATH = "./images"

var errorImages = []string{}

func ImageRedict(c echo.Context) error {
	url := c.QueryParam("url")
	ss := strings.Split(url, "/")
	imageName := ss[len(ss)-1]
	for _, x := range errorImages {
		if x == imageName {
			return c.File(IMAGEPATH + "/default.png")
		}
	}
	err := readRemoteImage(url, imageName)
	if err != nil {
		return c.File(IMAGEPATH + "/default.png")
	}

	return c.File(IMAGEPATH + "/" + imageName)

}

func readRemoteImage(url string, imageName string) error {

	files, err := ioutil.ReadDir(IMAGEPATH)
	if err != nil {
		os.Mkdir(IMAGEPATH, os.ModePerm)
	}
	for _, f := range files {

		if f.Name() == imageName {
			return nil
		}

	}

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		errorImages = append(errorImages, imageName)
		return errors.New("error")
	}

	pix, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(IMAGEPATH+"/"+imageName, pix, 0666)
	return nil

}

func ImageGroup(e *echo.Echo) {
	t := e.Group("/image")

	t.GET("", ImageRedict)

}
