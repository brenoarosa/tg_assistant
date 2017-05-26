/*
 * Copyright (c) 2015 Oleg Morozenkov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef TGBOT_TGWEBHOOKTCPSERVER_H
#define TGBOT_TGWEBHOOKTCPSERVER_H

#ifdef BOOST_ASIO_HAS_LOCAL_SOCKETS

#include "tgbot/net/TgWebhookServer.h"

namespace TgBot {

/**
 * This class setups HTTP server for receiving Telegram Update objects from unix socket.
 * @ingroup net
 */
class TgWebhookLocalServer : public TgWebhookServer<boost::asio::local::stream_protocol> {

public:
	TgWebhookLocalServer(std::shared_ptr<boost::asio::basic_socket_acceptor<boost::asio::local::stream_protocol>>& acceptor, const std::string& path, EventHandler* eventHandler) = delete;

	TgWebhookLocalServer(const std::string& path, const EventHandler* eventHandler) :
		TgWebhookServer<boost::asio::local::stream_protocol>(std::shared_ptr<boost::asio::basic_socket_acceptor<boost::asio::local::stream_protocol>>(new boost::asio::local::stream_protocol::acceptor(_ioService, boost::asio::local::stream_protocol::endpoint(path))), path, eventHandler)
	{
	}

	TgWebhookLocalServer(const std::string& path, const Bot& bot) : TgWebhookLocalServer(path, &bot.getEventHandler()) {
	}
};

}

#endif //BOOST_ASIO_HAS_LOCAL_SOCKETS

#endif //TGBOT_TGWEBHOOKTCPSERVER_H
