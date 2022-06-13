using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace Bookvault.Inventory.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class InventoryController : Controller
    {
        private readonly IMemoryCache _memoryCache;
        private readonly ILogger<InventoryController> _logger;

        public InventoryController(IMemoryCache memoryCache, ILogger<InventoryController> logger)
        {
            _memoryCache=memoryCache;
            _logger=logger;
        }

        [HttpGet(Name = "GetInventoryCount")]
        public ActionResult<int> Get(string productId)
        {
            var memCacheKey = $"{productId}-inventory";
            int inventoryValue = -404;

            if (!_memoryCache.TryGetValue(memCacheKey, out inventoryValue))
            {
                inventoryValue = new Random().Next(1, 100);
                _memoryCache.Set(memCacheKey, inventoryValue);
            }

            inventoryValue = _memoryCache.Get<int>(memCacheKey);

            return new OkObjectResult(inventoryValue);
        }
    }
}
