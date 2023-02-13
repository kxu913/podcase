package route

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/labstack/echo"

	sarama "github.com/Shopify/sarama"
)

var (
	topic         = "usage"
	brokerAddress = []string{os.Getenv("address")}
)

func SendMessage(c echo.Context) error {

	config := sarama.NewConfig()

	config.Producer.Return.Successes = true

	config.Producer.RequiredAcks = sarama.WaitForAll

	// config.Producer.Partitioner = sarama.NewRandomPartitioner
	fmt.Println(brokerAddress)
	client, err := sarama.NewClient(brokerAddress, config)
	producer, err := sarama.NewAsyncProducerFromClient(client)

	if err != nil {
		return c.JSON(http.StatusInternalServerError, "Server Errors")
	}
	defer producer.Close()

	msg := &sarama.ProducerMessage{
		Topic:     topic,
		Partition: int32(0),
		Key:       sarama.StringEncoder("usage"),
	}
	r := c.Request()
	bodyBuffer := r.Body
	buf, err := ioutil.ReadAll(bodyBuffer)
	if err != nil {
		return c.JSON(http.StatusNotAcceptable, "invalid post body")
	}
	msg.Value = sarama.ByteEncoder(buf)
	producer.Input() <- msg

	select {
	case suc := <-producer.Successes():
		return c.JSON(http.StatusOK, map[string]any{"paritition": suc.Partition, "offset": suc.Offset})

	case fail := <-producer.Errors():
		fmt.Printf("err: %s\n", fail.Err.Error())
		return c.JSON(http.StatusNotAcceptable, "send to kafka failed.")
	}

}

func MessageGroup(e *echo.Echo) {
	t := e.Group("/msg")

	t.POST("/usage", SendMessage)

}
