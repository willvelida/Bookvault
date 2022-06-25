using Bookvault.Web.Data.Interfaces;
using Refit;

namespace Bookvault.Web.Data
{
    public class BookvaultBackendClient : IBookvaultBackendClient
    {
        IHttpClientFactory _httpClientFactory;

        public BookvaultBackendClient(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task DeleteBookById(long id)
        {
            var client = _httpClientFactory.CreateClient("Books");
            await RestService.For<IBookvaultBackendClient>(client).DeleteBookById(id);
        }

        public async Task<Book> GetBookById(long id)
        {
            var client = _httpClientFactory.CreateClient("Books");
            return await RestService.For<IBookvaultBackendClient>(client).GetBookById(id);
        }

        public async Task<List<Book>> GetBooks()
        {
            var client = _httpClientFactory.CreateClient("Books");
            return await RestService.For<IBookvaultBackendClient>(client).GetBooks();
        }

        public async Task<int> GetInventory(int productId)
        {
            var client = _httpClientFactory.CreateClient("Inventory");
            return await RestService.For<IBookvaultBackendClient>(client).GetInventory(productId);
        }

        public async Task<Book> PostBook(Book book)
        {
            var client = _httpClientFactory.CreateClient("Books");
            return await RestService.For<IBookvaultBackendClient>(client).PostBook(book);
        }

        public async Task UpdateBookById(long id, Book book)
        {
            var client = _httpClientFactory.CreateClient("Books");
            await RestService.For<IBookvaultBackendClient>(client).UpdateBookById(id, book);
        }
    }
}
