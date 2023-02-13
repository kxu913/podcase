package route

import (
	"net/http"

	"github.com/labstack/echo"

	search "kevin_913/rssfeed/search"
)

type SearchCondition struct {
	Field    string
	Keyword  string
	Includes []string
	From     int
	Size     int
}

func setDefaultValue(sc *SearchCondition) *SearchCondition {

	if sc.Size == 0 {
		sc.Size = 10
	}
	return sc

}

func Search(c echo.Context) error {
	sc := &SearchCondition{}
	if err := c.Bind(sc); err != nil {
		return c.JSON(http.StatusNotAcceptable, "invalid post body")
	}

	_sc := setDefaultValue(sc)

	results := search.SearchEntry(_sc.Field, _sc.Keyword, _sc.Includes, _sc.From, _sc.Size)
	return c.JSON(http.StatusOK, results)

}

func SearchFeed(c echo.Context) error {

	results := search.SearchFeed()
	return c.JSON(http.StatusOK, results)

}

func SearchGroup(e *echo.Echo) {
	t := e.Group("/api")
	t.POST("/search", Search)
	t.GET("/feeds", SearchFeed)

}
