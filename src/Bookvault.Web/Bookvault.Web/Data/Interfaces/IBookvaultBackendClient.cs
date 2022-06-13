using Refit;

namespace Bookvault.Web.Data.Interfaces
{
    public interface IBookvaultBackendClient
    {
        [Get("/books")]
        Task<List<Book>> GetBooks();

        [Get("/inventory/{productId}")]
        Task<int> GetInventory(string productId);
    }
}
