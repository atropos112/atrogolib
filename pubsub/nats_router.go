package pubsub

import (
	"log/slog"
	"time"

	"github.com/ThreeDotsLabs/watermill"
	"github.com/ThreeDotsLabs/watermill/message"
	"github.com/ThreeDotsLabs/watermill/message/router/middleware"
	"github.com/ThreeDotsLabs/watermill/message/router/plugin"
)

const DefaultTimeout = 10 * time.Second

func NewEventNATSRouter(l *slog.Logger) *message.Router {
	watermillLogger := watermill.NewSlogLogger(l)

	router, err := message.NewRouter(message.RouterConfig{}, watermillLogger)
	if err != nil {
		panic(err)
	}

	router.AddPlugin(plugin.SignalsHandler)

	router.AddMiddleware(
		// Add timeout to context, in case of a timeout, the message will be nacked.
		middleware.Timeout(DefaultTimeout),

		// Add correlation ID to context,
		middleware.CorrelationID,
	)

	return router
}
