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

        public async Task<List<Book>> GetBooks()
        {
            var client = _httpClientFactory.CreateClient("Books");
            return await RestService.For<IBookvaultBackendClient>(client).GetBooks();
        }

        public async Task<int> GetInventory(string productId)
        {
            var client = _httpClientFactory.CreateClient("Inventory");
            return await RestService.For<IBookvaultBackendClient>(client).GetInventory(productId);
        }
    }
}
