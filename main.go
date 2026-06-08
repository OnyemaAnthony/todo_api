package main

import (
	"go-todo-rest-api/config"
	"go-todo-rest-api/database"
	"go-todo-rest-api/handler"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {

	var cfg *config.Config
	var err error
	cfg, err = config.Load()
	if err != nil {
		log.Fatal(err)

	}
	var pool *pgxpool.Pool
	pool, err = database.Connect(cfg.DatabaseUrl)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()
	var router *gin.Engine = gin.Default()
	router.SetTrustedProxies(nil)
	//
	//router.GET("/", func(c *gin.Context) {
	//	c.JSON(200, gin.H{"hello": "world guys "})
	//})
	router.POST("/todos", handler.CreateTodoHandler(pool))
	router.GET("/todos", handler.GetTodosHandler(pool))

	router.Run(":" + cfg.Port)

}
